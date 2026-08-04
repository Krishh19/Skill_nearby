-- SkillNearby Seed Data for Remote Database Testing

-- 1. Insert auth users first to satisfy foreign key constraint
insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'rohan@example.com', extensions.crypt('Neighbour123!', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Rohan Mehta"}', now(), now()),
  ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'neha@example.com', extensions.crypt('Neighbour123!', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Neha Verma"}', now(), now()),
  ('33333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'arjun@example.com', extensions.crypt('Neighbour123!', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Arjun Patel"}', now(), now()),
  ('44444444-4444-4444-4444-444444444444', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'maya@example.com', extensions.crypt('Neighbour123!', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Maya Rao"}', now(), now())
on conflict (id) do nothing;

-- 2. Insert initial sample profiles into public.profiles
insert into public.profiles (id, display_name, bio, location, radius_km, is_available, is_verified, subscription_tier)
values
  ('11111111-1111-1111-1111-111111111111', 'Rohan Mehta', 'Acoustic guitar player & coffee enthusiast. Happy to teach chords!', extensions.ST_SetSRID(extensions.ST_MakePoint(77.2090, 28.6139), 4326)::extensions.geography, 5, true, true, 'plus'),
  ('22222222-2222-2222-2222-222222222222', 'Neha Verma', 'UI designer & yogi. Offering video editing and Figma tips.', extensions.ST_SetSRID(extensions.ST_MakePoint(77.2150, 28.6180), 4326)::extensions.geography, 2, true, true, 'free'),
  ('33333333-3333-3333-3333-333333333333', 'Arjun Patel', 'Home baker specializing in sourdough & artisan loaves.', extensions.ST_SetSRID(extensions.ST_MakePoint(77.2000, 28.6050), 4326)::extensions.geography, 5, true, false, 'free'),
  ('44444444-4444-4444-4444-444444444444', 'Maya Rao', 'Handyman & bicycle mechanics. Can help fix squeaky chains!', extensions.ST_SetSRID(extensions.ST_MakePoint(77.2200, 28.6250), 4326)::extensions.geography, 10, true, true, 'plus')
on conflict (id) do update set
  display_name = excluded.display_name,
  bio = excluded.bio,
  location = excluded.location;

-- 3. Insert skills for profiles
insert into public.skills (profile_id, name, direction)
values
  ('11111111-1111-1111-1111-111111111111', 'Guitar Lessons', 'offer'),
  ('11111111-1111-1111-1111-111111111111', 'Ukulele', 'offer'),
  ('11111111-1111-1111-1111-111111111111', 'Graphic Design', 'want'),
  ('22222222-2222-2222-2222-222222222222', 'Video Editing', 'offer'),
  ('22222222-2222-2222-2222-222222222222', 'Figma Basics', 'offer'),
  ('22222222-2222-2222-2222-222222222222', 'Yoga', 'offer'),
  ('22222222-2222-2222-2222-222222222222', 'Sourdough Baking', 'want'),
  ('33333333-3333-3333-3333-333333333333', 'Sourdough Baking', 'offer'),
  ('33333333-3333-3333-3333-333333333333', 'Meal Prep', 'offer'),
  ('33333333-3333-3333-3333-333333333333', 'Cycle Repair', 'want'),
  ('44444444-4444-4444-4444-444444444444', 'Cycle Repair', 'offer'),
  ('44444444-4444-4444-4444-444444444444', 'Furniture Assembly', 'offer'),
  ('44444444-4444-4444-4444-444444444444', 'Guitar Lessons', 'want')
on conflict (profile_id, name, direction) do nothing;

-- 4. Insert sample swaps
insert into public.swaps (id, requester_id, recipient_id, wanted_skill, offered_skill, message, status)
values
  ('a1111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Guitar Lessons', 'Video Editing', 'Hey Rohan! Would love to swap guitar lessons for video editing tips.', 'completed'),
  ('a2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Video Editing', 'Guitar Lessons', 'Hi Neha! Happy to teach you chords.', 'completed'),
  ('a3333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 'Sourdough Baking', 'Cycle Repair', 'Hey Arjun! Sourdough starter for a bike tune up?', 'completed')
on conflict (id) do nothing;

-- 5. Insert sample ratings
insert into public.ratings (swap_id, reviewer_id, reviewee_id, score, note)
values
  ('a1111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 5, 'Super patient acoustic guitar teacher!'),
  ('a2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 5, 'Amazing video editing tips and shortcuts!'),
  ('a3333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 5, 'The sourdough loaf was delicious and easy to follow.')
on conflict (swap_id, reviewer_id) do nothing;
