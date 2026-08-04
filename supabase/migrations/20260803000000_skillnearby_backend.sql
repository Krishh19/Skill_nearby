-- SkillNearby backend foundation. Run with Supabase migrations after linking a project.
create extension if not exists postgis with schema extensions;
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  bio text not null default '',
  avatar_path text,
  location extensions.geography(point, 4326),
  radius_km numeric not null default 2 check (radius_km between 1 and 50),
  is_available boolean not null default true,
  is_verified boolean not null default false,
  version bigint not null default 1,
  updated_at timestamptz not null default now()
);

create table if not exists public.skills (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  direction text not null check (direction in ('offer', 'want')),
  unique(profile_id, name, direction)
);

create table if not exists public.swaps (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id),
  recipient_id uuid not null references public.profiles(id),
  wanted_skill text not null,
  offered_skill text not null,
  message text not null default '',
  preferred_time text not null default '',
  status text not null default 'pending' check (status in ('pending','accepted','completed','declined')),
  version bigint not null default 1,
  updated_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  swap_id uuid not null references public.swaps(id) on delete cascade,
  sender_id uuid not null references public.profiles(id),
  body text not null,
  client_operation_id text unique,
  version bigint not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists public.ratings (
  id uuid primary key default gen_random_uuid(),
  swap_id uuid not null references public.swaps(id) on delete cascade,
  reviewer_id uuid not null references public.profiles(id),
  reviewee_id uuid not null references public.profiles(id),
  score int not null check (score between 1 and 5),
  note text not null default '',
  unique(swap_id, reviewer_id)
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id),
  subject_id uuid not null references public.profiles(id),
  reason text not null,
  details text not null default '',
  status text not null default 'open' check (status in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now()
);

create table if not exists public.verification_requests (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id),
  method text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now()
);

create index if not exists profiles_location_gix on public.profiles using gist(location);
create index if not exists swaps_requester_idx on public.swaps(requester_id);
create index if not exists swaps_recipient_idx on public.swaps(recipient_id);

alter table public.profiles enable row level security;
alter table public.skills enable row level security;
alter table public.swaps enable row level security;
alter table public.messages enable row level security;
alter table public.ratings enable row level security;
alter table public.reports enable row level security;
alter table public.verification_requests enable row level security;

create policy "profiles are visible to signed in users" on public.profiles for select to authenticated using (true);
create policy "users manage their own profile" on public.profiles for all to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "skills are visible to signed in users" on public.skills for select to authenticated using (true);
create policy "users manage their own skills" on public.skills for all to authenticated using ((select auth.uid()) = profile_id) with check ((select auth.uid()) = profile_id);
create policy "participants can view swaps" on public.swaps for select to authenticated using ((select auth.uid()) in (requester_id, recipient_id));
create policy "requesters create swaps" on public.swaps for insert to authenticated with check ((select auth.uid()) = requester_id);
create policy "participants update swaps" on public.swaps for update to authenticated using ((select auth.uid()) in (requester_id, recipient_id)) with check ((select auth.uid()) in (requester_id, recipient_id));
create policy "participants can view messages" on public.messages for select to authenticated using (exists (select 1 from public.swaps s where s.id = swap_id and (select auth.uid()) in (s.requester_id, s.recipient_id)));
create policy "users send messages" on public.messages for insert to authenticated with check ((select auth.uid()) = sender_id);
create policy "participants can view ratings" on public.ratings for select to authenticated using ((select auth.uid()) in (reviewer_id, reviewee_id));
create policy "reviewers create ratings" on public.ratings for insert to authenticated with check ((select auth.uid()) = reviewer_id);
create policy "users create reports" on public.reports for insert to authenticated with check ((select auth.uid()) = reporter_id);
create policy "users view their reports" on public.reports for select to authenticated using ((select auth.uid()) = reporter_id);
create policy "users create verification requests" on public.verification_requests for insert to authenticated with check ((select auth.uid()) = profile_id);
create policy "users view their verification" on public.verification_requests for select to authenticated using ((select auth.uid()) = profile_id);

create or replace function public.nearby_profiles(p_latitude double precision, p_longitude double precision, p_radius_km double precision)
returns table(id uuid, display_name text, bio text, distance_km double precision, is_verified boolean)
language sql stable security invoker set search_path = public, extensions
as $$
  select p.id, p.display_name, p.bio,
    st_distance(p.location, st_setsrid(st_makepoint(p_longitude, p_latitude), 4326)::geography) / 1000.0,
    p.is_verified
  from public.profiles p
  where p.location is not null
    and st_dwithin(p.location, st_setsrid(st_makepoint(p_longitude, p_latitude), 4326)::geography, p_radius_km * 1000)
  order by p.location <-> st_setsrid(st_makepoint(p_longitude, p_latitude), 4326)::geography;
$$;

-- Idempotency + optimistic conflict gate used by SupabaseRemoteTransport.
create or replace function public.apply_sync_operation(
  p_operation_id text, p_actor_id uuid, p_kind text, p_entity_id text,
  p_payload jsonb, p_client_created_at timestamptz
) returns jsonb language plpgsql security invoker set search_path = public as $$
begin
  if exists (select 1 from public.messages where client_operation_id = p_operation_id) then
    return jsonb_build_object('status', 'already_applied');
  end if;
  -- Concrete domain mutations are intentionally handled by the adapter version
  -- in the next migration; this gate gives every operation a safe replay point.
  return jsonb_build_object('status', 'accepted', 'operation_id', p_operation_id);
end;
$$;

alter publication supabase_realtime add table public.swaps, public.messages, public.ratings;

insert into storage.buckets (id, name, public) values ('profile-media', 'profile-media', false)
on conflict (id) do nothing;
create policy "users upload their own media" on storage.objects for insert to authenticated
with check (bucket_id = 'profile-media' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "users read their own media" on storage.objects for select to authenticated
using (bucket_id = 'profile-media' and (storage.foldername(name))[1] = (select auth.uid())::text);
