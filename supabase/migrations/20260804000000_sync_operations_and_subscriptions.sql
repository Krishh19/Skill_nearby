-- SkillNearby Backend Phase 2: Concrete Sync Operations, Auth Bootstrap, & Subscription Monetization

-- 1. Add subscription monetization columns to public.profiles
alter table public.profiles
  add column if not exists subscription_tier text not null default 'free' check (subscription_tier in ('free', 'plus', 'pro')),
  add column if not exists subscription_expires_at timestamptz;

-- 2. Auth user creation trigger: auto-bootstrap public.profiles row on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name, bio, avatar_path)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'Neighbour'),
    coalesce(new.raw_user_meta_data->>'bio', ''),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do update set
    display_name = excluded.display_name,
    avatar_path = coalesce(excluded.avatar_path, profiles.avatar_path);
  return new;
end;
$$;

-- Attach trigger to auth.users if not already created
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 3. Enriched PostGIS nearby_profiles RPC with Skill Aggregation & Free-Tier Radius Capping
drop function if exists public.nearby_profiles(double precision, double precision, double precision);
create or replace function public.nearby_profiles(
  p_latitude double precision,
  p_longitude double precision,
  p_radius_km double precision
)
returns table(
  id uuid,
  display_name text,
  bio text,
  distance_km double precision,
  rating double precision,
  is_verified boolean,
  offers jsonb,
  wants jsonb
)
language plpgsql stable security invoker set search_path = public, extensions as $$
declare
  v_user_tier text := 'free';
  v_effective_radius double precision;
begin
  -- Fetch requesting user's subscription tier
  select subscription_tier into v_user_tier
  from public.profiles
  where id = (select auth.uid());

  -- Enforce 2 km radius limit on free tier, allow larger radii on plus/pro
  if coalesce(v_user_tier, 'free') = 'free' then
    v_effective_radius := least(p_radius_km, 2.0);
  else
    v_effective_radius := p_radius_km;
  end if;

  return query
  select
    p.id,
    p.display_name,
    p.bio,
    st_distance(p.location, st_setsrid(st_makepoint(p_longitude, p_latitude), 4326)::geography) / 1000.0 as distance_km,
    coalesce((select avg(score)::double precision from public.ratings r where r.reviewee_id = p.id), 5.0) as rating,
    p.is_verified,
    coalesce((select jsonb_agg(s.name) from public.skills s where s.profile_id = p.id and s.direction = 'offer'), '[]'::jsonb) as offers,
    coalesce((select jsonb_agg(s.name) from public.skills s where s.profile_id = p.id and s.direction = 'want'), '[]'::jsonb) as wants
  from public.profiles p
  where p.location is not null
    and (select auth.uid() is null or p.id != auth.uid())
    and st_dwithin(p.location, st_setsrid(st_makepoint(p_longitude, p_latitude), 4326)::geography, v_effective_radius * 1000)
  order by p.location <-> st_setsrid(st_makepoint(p_longitude, p_latitude), 4326)::geography;
end;
$$;

-- 4. Concrete Sync Operations Dispatcher & Optimistic Conflict Gate
create or replace function public.apply_sync_operation(
  p_operation_id text,
  p_actor_id uuid,
  p_kind text,
  p_entity_id text,
  p_payload jsonb,
  p_client_created_at timestamptz
)
returns jsonb
language plpgsql security invoker set search_path = public as $$
declare
  v_recipient_id uuid;
  v_swap_id uuid;
  v_server_updated_at timestamptz;
begin
  -- Idempotency check for messages
  if exists (select 1 from public.messages where client_operation_id = p_operation_id) then
    return jsonb_build_object('status', 'already_applied', 'operation_id', p_operation_id);
  end if;

  -- Dispatch by operation kind
  if p_kind = 'requestSwap' then
    v_recipient_id := (p_payload->>'profile_id')::uuid;

    insert into public.swaps (
      id, requester_id, recipient_id, wanted_skill, offered_skill, message, preferred_time, status, updated_at
    )
    values (
      p_entity_id::uuid,
      p_actor_id,
      v_recipient_id,
      coalesce(p_payload->>'wanted_skill', ''),
      coalesce(p_payload->>'offered_skill', ''),
      coalesce(p_payload->>'message', ''),
      coalesce(p_payload->>'preferred_time', ''),
      'pending',
      now()
    )
    on conflict (id) do update set
      status = excluded.status,
      updated_at = now();

    return jsonb_build_object('status', 'accepted', 'kind', p_kind, 'entity_id', p_entity_id);

  elsif p_kind = 'sendMessage' then
    v_swap_id := (p_payload->>'profile_id')::uuid; -- Maps profileId or swapId

    insert into public.messages (
      id, swap_id, sender_id, body, client_operation_id, created_at
    )
    values (
      p_entity_id::uuid,
      v_swap_id,
      p_actor_id,
      coalesce(p_payload->>'body', ''),
      p_operation_id,
      now()
    )
    on conflict (id) do nothing;

    return jsonb_build_object('status', 'accepted', 'kind', p_kind, 'entity_id', p_entity_id);

  elsif p_kind = 'completeSwap' then
    select updated_at into v_server_updated_at
    from public.swaps
    where id = p_entity_id::uuid;

    -- Conflict check if remote row was updated after client created operation
    if v_server_updated_at is not null and v_server_updated_at > p_client_created_at + interval '1 minute' then
      return jsonb_build_object(
        'status', 'conflict',
        'entity_id', p_entity_id,
        'server_updated_at', v_server_updated_at
      );
    end if;

    update public.swaps
    set status = 'completed', version = version + 1, updated_at = now()
    where id = p_entity_id::uuid;

    return jsonb_build_object('status', 'accepted', 'kind', p_kind, 'entity_id', p_entity_id);

  elsif p_kind = 'submitRating' then
    insert into public.ratings (
      swap_id, reviewer_id, reviewee_id, score, note
    )
    values (
      p_entity_id::uuid,
      p_actor_id,
      coalesce((p_payload->>'reviewee_id')::uuid, p_actor_id),
      coalesce((p_payload->>'score')::int, 5),
      coalesce(p_payload->>'note', '')
    )
    on conflict (swap_id, reviewer_id) do update set
      score = excluded.score,
      note = excluded.note;

    return jsonb_build_object('status', 'accepted', 'kind', p_kind, 'entity_id', p_entity_id);
  else
    return jsonb_build_object('status', 'accepted', 'kind', p_kind, 'entity_id', p_entity_id);
  end if;
end;
$$;
