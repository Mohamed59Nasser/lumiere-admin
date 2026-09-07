-- Run this file once in Supabase SQL Editor.
create table if not exists public.products (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.users (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  user_id text not null references public.users(id) on delete cascade,
  order_key text not null,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, order_key)
);

create table if not exists public.coupons (
  code text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.settings (
  id text primary key default 'store',
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.admins (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  name text not null,
  role text not null default 'admin',
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;
alter table public.users enable row level security;
alter table public.orders enable row level security;
alter table public.coupons enable row level security;
alter table public.settings enable row level security;
alter table public.admins enable row level security;

drop policy if exists "Public can read products" on public.products;
create policy "Public can read products" on public.products for select using (true);

drop policy if exists "Admins manage products" on public.products;
create policy "Admins manage products" on public.products for all to authenticated
  using (exists (select 1 from public.admins where id = auth.uid()))
  with check (exists (select 1 from public.admins where id = auth.uid()));

drop policy if exists "Admins manage users" on public.users;
create policy "Admins manage users" on public.users for all to authenticated
  using (exists (select 1 from public.admins where id = auth.uid()))
  with check (exists (select 1 from public.admins where id = auth.uid()));

drop policy if exists "Admins manage orders" on public.orders;
create policy "Admins manage orders" on public.orders for all to authenticated
  using (exists (select 1 from public.admins where id = auth.uid()))
  with check (exists (select 1 from public.admins where id = auth.uid()));

drop policy if exists "Public can read coupons" on public.coupons;
create policy "Public can read coupons" on public.coupons for select using (true);

drop policy if exists "Admins manage coupons" on public.coupons;
create policy "Admins manage coupons" on public.coupons for all to authenticated
  using (exists (select 1 from public.admins where id = auth.uid()))
  with check (exists (select 1 from public.admins where id = auth.uid()));

drop policy if exists "Public can read settings" on public.settings;
create policy "Public can read settings" on public.settings for select using (true);

drop policy if exists "Admins manage settings" on public.settings;
create policy "Admins manage settings" on public.settings for all to authenticated
  using (exists (select 1 from public.admins where id = auth.uid()))
  with check (exists (select 1 from public.admins where id = auth.uid()));

drop policy if exists "Admins read admins" on public.admins;
create policy "Admins read admins" on public.admins for select to authenticated
  using (exists (select 1 from public.admins where id = auth.uid()));

drop policy if exists "Admins insert admins" on public.admins;
create policy "Admins insert admins" on public.admins for insert to authenticated
  with check (exists (select 1 from public.admins where id = auth.uid()));
