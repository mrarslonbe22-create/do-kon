-- ============================================
-- VIP MARKET — Supabase ma'lumotlar bazasi sxemasi
-- Buni Supabase loyihangizdagi SQL Editor'ga joylab, "Run" tugmasini bosing.
-- ============================================

-- 1. DO'KONLAR jadvali
create table stores (
  id text primary key,
  name text not null,
  category text,
  region text,
  direction text,
  address text,
  services text[] default '{}',       -- masalan: {dokon,uyga}
  phone text,
  username text,
  password text,                       -- eslatma: haqiqiy loyihada parolni hech qachon ochiq matnda saqlamang!
  status text default 'approved',      -- approved | pending | rejected
  lat double precision,
  lng double precision,
  created_at timestamptz default now()
);

-- 2. MAHSULOTLAR jadvali
create table products (
  id bigint generated always as identity primary key,
  store_id text references stores(id) on delete cascade,
  cat text,
  icon text,
  img text,
  title text not null,
  price numeric not null,
  old_price numeric default 0,
  tag text,
  delivery text[] default '{}',        -- {dokon,uyga}
  desc text,
  sizes text[] default '{}',
  is_flash boolean default false,
  created_at timestamptz default now()
);

-- 3. BUYURTMALAR jadvali
create table orders (
  order_num text primary key,
  store_id text references stores(id),
  customer_name text not null,
  phone text not null,
  method text not null,                -- dokon | uyga
  address text,
  items jsonb not null,                -- [{title, qty, price, size}]
  total numeric not null,
  status text default 'yangi',         -- yangi | qadoqlanmoqda | kuryerga_berildi | yetkazildi
  courier text,
  seen boolean default false,
  created_at timestamptz default now()
);

-- 4. DO'KON QO'SHILISH SO'ROVLARI jadvali
create table store_requests (
  id bigint generated always as identity primary key,
  name text not null,
  category text,
  region text,
  direction text,
  address text,
  phone text,
  services text[] default '{}',
  status text default 'pending',       -- pending | approved | rejected
  created_at timestamptz default now()
);

-- ============================================
-- Xavfsizlik siyosati (Row Level Security)
-- Boshlang'ich bosqichda o'qish uchun ochiq, yozish uchun cheklangan.
-- Keyinchalik Supabase Auth bilan har bir do'kon o'z ma'lumotini
-- boshqarishi uchun policy'larni qattiqlashtirish tavsiya etiladi.
-- ============================================
alter table stores enable row level security;
alter table products enable row level security;
alter table orders enable row level security;
alter table store_requests enable row level security;

create policy "Public read stores" on stores for select using (true);
create policy "Public read products" on products for select using (true);
create policy "Public insert orders" on orders for insert with check (true);
create policy "Public read own orders by number" on orders for select using (true);
create policy "Public insert store_requests" on store_requests for insert with check (true);

-- Admin panel orqali yozish (hozircha ochiq — anon key bilan ishlaydi,
-- keyinchalik Supabase Auth qo'shilganda bu policy'lar kuchaytiriladi)
create policy "Admin write stores" on stores for all using (true) with check (true);
create policy "Admin write products" on products for all using (true) with check (true);
create policy "Admin update orders" on orders for update using (true);
create policy "Admin manage requests" on store_requests for update using (true);

-- ============================================
-- Boshlang'ich namuna ma'lumotlar (ixtiyoriy)
-- ============================================
insert into stores (id, name, category, region, direction, address, services, phone, username, password)
values
  ('main', 'VIP MARKET Bosh do''koni', 'Aralash mahsulotlar', 'Toshkent shahri', 'Chilonzor',
   'Toshkent sh., Chilonzor tumani, Bunyodkor shoh ko''chasi 1', '{dokon,uyga}', '+998712000000', 'main', 'vip2026'),
  ('yaypan', 'Yaypan Parfumeriya', 'Parfumeriya', 'Farg''ona viloyati', 'Yaypan tumani',
   'Farg''ona viloyati, Yaypan tumani, Mustaqillik ko''chasi 12', '{dokon}', '+998735551122', 'yaypan', 'yaypan2026');
