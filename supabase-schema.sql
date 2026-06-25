-- ============================================================
-- PolarNote — Supabase schema
-- Run this ONCE in your Supabase project:
--   Dashboard → SQL Editor → New query → paste → Run
-- ============================================================

-- 1. Profile (one row per authenticated user) -----------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  name        text,
  dx          text,
  start_date  date default current_date,
  settings    jsonb default '{}'::jsonb,   -- notification prefs (toggles, reminder time, weekly day)
  created_at  timestamptz default now()
);

-- (for existing projects created before the settings column was added)
alter table public.profiles add column if not exists settings jsonb default '{}'::jsonb;

-- 2. Daily check-in entries (many per user, one per date) ------
create table if not exists public.entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  date        date not null,
  bed_min     int,
  wake_min    int,
  sleep_h     numeric,
  sleep_segments jsonb default '[]'::jsonb,  -- full night incl. interruptions: [{bedMin,wakeMin},...]
  mood        int,
  zone        text,
  flags       jsonb default '[]'::jsonb,
  note        text,                  -- optional evening reflection (second check-in)
  ts          bigint,
  created_at  timestamptz default now(),
  unique (user_id, date)            -- one entry per user per day
);

-- (for existing projects created before the note column was added)
alter table public.entries add column if not exists note text;

-- (for existing projects created before interrupted-sleep tracking was added)
alter table public.entries add column if not exists sleep_segments jsonb default '[]'::jsonb;

create index if not exists entries_user_date_idx
  on public.entries (user_id, date);

-- 3. Row Level Security: each user sees ONLY their own data ----
alter table public.profiles enable row level security;
alter table public.entries  enable row level security;

drop policy if exists "own profile" on public.profiles;
create policy "own profile" on public.profiles
  for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "own entries" on public.entries;
create policy "own entries" on public.entries
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
