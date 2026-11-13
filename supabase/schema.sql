-- ============================================================
-- PROTOCOLO Z - SCHEMA COMPLETO E DADOS INICIAIS
-- ============================================================

-- 1. EXTENSOES
create extension if not exists "uuid-ossp";

-- ============================================================
-- 2. TABELAS
-- ============================================================

create table public.factions (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  symbol text not null,
  color text not null,
  description text,
  created_at timestamptz default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null,
  avatar_url text,
  faction_id uuid references public.factions(id),
  reputation int not null default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.items (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  category text not null check (category in ('água', 'comida', 'medicamentos', 'ferramentas', 'combustível')),
  icon text,
  created_at timestamptz default now()
);

create table public.inventory (
  id uuid primary key default uuid_generate_v4(),
  player_id uuid not null references public.profiles(id) on delete cascade,
  item_id uuid not null references public.items(id) on delete cascade,
  quantity int not null default 0 check (quantity >= 0),
  updated_at timestamptz default now(),
  unique (player_id, item_id)
);

create table public.shelters (
  id uuid primary key default uuid_generate_v4(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  description text,
  capacity int,
  photo_url text,
  latitude double precision not null,
  longitude double precision not null,
  visibility text not null check (visibility in ('public', 'faction')) default 'public',
  status text not null check (status in ('safe', 'compromised')) default 'safe',
  created_at timestamptz default now()
);

create table public.expedition_types (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  duration_seconds int not null,
  risk text not null check (risk in ('baixo', 'médio', 'alto')),
  created_at timestamptz default now()
);

create table public.expedition_rewards (
  id uuid primary key default uuid_generate_v4(),
  expedition_type_id uuid not null references public.expedition_types(id) on delete cascade,
  item_id uuid not null references public.items(id) on delete cascade,
  min_quantity int not null default 1,
  max_quantity int not null default 3
);

create table public.expeditions (
  id uuid primary key default uuid_generate_v4(),
  player_id uuid not null references public.profiles(id) on delete cascade,
  expedition_type_id uuid not null references public.expedition_types(id),
  started_at timestamptz not null default now(),
  ends_at timestamptz not null,
  collected_at timestamptz,
  status text not null check (status in ('em_andamento', 'pronta', 'coletada', 'falhou')) default 'em_andamento'
);

create table public.trades (
  id uuid primary key default uuid_generate_v4(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  status text not null check (status in ('pendente', 'aceita', 'recusada', 'cancelada', 'expirada')) default 'pendente',
  created_at timestamptz default now(),
  expires_at timestamptz not null default now() + interval '24 hours',
  check (author_id <> recipient_id)
);

create table public.trade_items (
  id uuid primary key default uuid_generate_v4(),
  trade_id uuid not null references public.trades(id) on delete cascade,
  item_id uuid not null references public.items(id),
  quantity int not null check (quantity > 0),
  direction text not null check (direction in ('oferecido', 'pedido')),
  unique (trade_id, item_id, direction)
);

create table public.horde_alerts (
  id uuid primary key default uuid_generate_v4(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  intensity text not null check (intensity in ('baixa', 'média', 'alta')),
  description text,
  created_at timestamptz default now(),
  expires_at timestamptz not null default now() + interval '30 minutes',
  reputation_granted boolean default false
);

create table public.alert_confirmations (
  id uuid primary key default uuid_generate_v4(),
  alert_id uuid not null references public.horde_alerts(id) on delete cascade,
  player_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique (alert_id, player_id)
);

-- ============================================================
-- 3. INDICES
-- ============================================================
create index idx_inventory_player on public.inventory(player_id);
create index idx_shelters_author on public.shelters(author_id);
create index idx_expeditions_player on public.expeditions(player_id);
create index idx_trades_author on public.trades(author_id);
create index idx_trades_recipient on public.trades(recipient_id);
create index idx_horde_alerts_expires on public.horde_alerts(expires_at);
create index idx_alert_confirmations_alert on public.alert_confirmations(alert_id);

-- ============================================================
-- 4. TRIGGERS E FUNCOES AUXILIARES
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nickname)
  values (new.id, coalesce(new.raw_user_meta_data->>'nickname', split_part(new.email, '@', 1)));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.update_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger update_profiles_updated_at
  before update on public.profiles
  for each row execute function public.update_updated_at();

create trigger update_inventory_updated_at
  before update on public.inventory
  for each row execute function public.update_updated_at();

-- ============================================================
-- 5. FUNCOES RPC (REGRAS DE NEGOCIO NO SERVIDOR)
-- ============================================================

create or replace function public.choose_faction(p_faction_id uuid)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_player_id uuid := auth.uid();
  v_current_faction uuid;
  v_kit record;
begin
  select faction_id into v_current_faction from profiles where id = v_player_id;
  if v_current_faction is not null then
    raise exception 'Voce ja escolheu uma faccao. A escolha e definitiva.';
  end if;

  if not exists (select 1 from factions where id = p_faction_id) then
    raise exception 'Faccao invalida.';
  end if;

  update profiles set faction_id = p_faction_id where id = v_player_id;

  for v_kit in select id from items loop
    insert into inventory (player_id, item_id, quantity)
    values (v_player_id, v_kit.id, 5)
    on conflict (player_id, item_id) do update
      set quantity = inventory.quantity + 5;
  end loop;

  return jsonb_build_object('success', true, 'faction_id', p_faction_id);
end;
$$;

create or replace function public.start_expedition(p_expedition_type_id uuid)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_player_id uuid := auth.uid();
  v_duration int;
  v_expedition_id uuid;
begin
  if exists (select 1 from expeditions where player_id = v_player_id and status = 'em_andamento') then
    raise exception 'Voce ja tem uma expedicao em andamento.';
  end if;

  select duration_seconds into v_duration from expedition_types where id = p_expedition_type_id;

  if v_duration is null then
    raise exception 'Tipo de expedicao invalido.';
  end if;

  insert into expeditions (player_id, expedition_type_id, ends_at, status)
  values (v_player_id, p_expedition_type_id, now() + (v_duration || ' seconds')::interval, 'em_andamento')
  returning id into v_expedition_id;

  return jsonb_build_object('success', true, 'expedition_id', v_expedition_id);
end;
$$;

create or replace function public.collect_expedition_rewards(p_expedition_id uuid)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_player_id uuid := auth.uid();
  v_expedition record;
  v_reward record;
  v_qty int;
  v_rewards jsonb := '[]'::jsonb;
begin
  select * into v_expedition
  from expeditions
  where id = p_expedition_id and player_id = v_player_id and status = 'em_andamento'
  for update;

  if not found then
    raise exception 'Expedicao nao encontrada ou ja coletada.';
  end if;

  if v_expedition.ends_at > now() then
    raise exception 'A expedicao ainda nao terminou.';
  end if;

  for v_reward in
    select er.item_id, er.min_quantity, er.max_quantity, i.name
    from expedition_rewards er
    join items i on i.id = er.item_id
    where er.expedition_type_id = v_expedition.expedition_type_id
  loop
    v_qty := floor(random() * (v_reward.max_quantity - v_reward.min_quantity + 1) + v_reward.min_quantity)::int;
    
    insert into inventory (player_id, item_id, quantity)
    values (v_player_id, v_reward.item_id, v_qty)
    on conflict (player_id, item_id) do update
      set quantity = inventory.quantity + v_qty;

    v_rewards := v_rewards || jsonb_build_object('item', v_reward.name, 'quantity', v_qty);
  end loop;

  update expeditions set status = 'coletada', collected_at = now() where id = p_expedition_id;
  update profiles set reputation = reputation + 10 where id = v_player_id;

  return jsonb_build_object('success', true, 'rewards', v_rewards);
end;
$$;

create or replace function public.create_trade(
  p_recipient_id uuid,
  p_offered_items jsonb,
  p_requested_items jsonb
)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_author_id uuid := auth.uid();
  v_trade_id uuid;
  v_item jsonb;
begin
  if v_author_id = p_recipient_id then
    raise exception 'Voce nao pode propor uma troca para si mesmo.';
  end if;

  if not exists (select 1 from profiles where id = p_recipient_id and faction_id is not null) then
    raise exception 'Destinatario invalido.';
  end if;

  for v_item in select * from jsonb_array_elements(p_offered_items) loop
    if not exists (
      select 1 from inventory
      where player_id = v_author_id
        and item_id = (v_item->>'item_id')::uuid
        and quantity >= (v_item->>'quantity')::int
    ) then
      raise exception 'Voce nao possui quantidade suficiente de um dos itens oferecidos.';
    end if;
  end loop;

  insert into trades (author_id, recipient_id)
  values (v_author_id, p_recipient_id)
  returning id into v_trade_id;

  for v_item in select * from jsonb_array_elements(p_offered_items) loop
    insert into trade_items (trade_id, item_id, quantity, direction)
    values (v_trade_id, (v_item->>'item_id')::uuid, (v_item->>'quantity')::int, 'oferecido');
  end loop;

  for v_item in select * from jsonb_array_elements(p_requested_items) loop
    insert into trade_items (trade_id, item_id, quantity, direction)
    values (v_trade_id, (v_item->>'item_id')::uuid, (v_item->>'quantity')::int, 'pedido');
  end loop;

  return jsonb_build_object('success', true, 'trade_id', v_trade_id);
end;
$$;

create or replace function public.accept_trade(p_trade_id uuid)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_recipient_id uuid := auth.uid();
  v_trade record;
  v_item record;
begin
  select * into v_trade
  from trades
  where id = p_trade_id and recipient_id = v_recipient_id and status = 'pendente'
  for update;

  if not found then
    raise exception 'Troca nao encontrada, ja processada ou voce nao e o destinatario.';
  end if;

  if v_trade.expires_at < now() then
    update trades set status = 'expirada' where id = p_trade_id;
    raise exception 'Esta troca expirou.';
  end if;

  for v_item in select ti.item_id, ti.quantity from trade_items ti where ti.trade_id = p_trade_id and ti.direction = 'oferecido' loop
    if not exists (select 1 from inventory where player_id = v_trade.author_id and item_id = v_item.item_id and quantity >= v_item.quantity) then
      raise exception 'O autor nao possui mais os itens oferecidos. A troca falhou.';
    end if;
  end loop;

  for v_item in select ti.item_id, ti.quantity from trade_items ti where ti.trade_id = p_trade_id and ti.direction = 'pedido' loop
    if not exists (select 1 from inventory where player_id = v_recipient_id and item_id = v_item.item_id and quantity >= v_item.quantity) then
      raise exception 'Voce nao possui mais os itens necessarios. A troca falhou.';
    end if;
  end loop;

  for v_item in select item_id, quantity from trade_items where trade_id = p_trade_id and direction = 'oferecido' loop
    update inventory set quantity = quantity - v_item.quantity where player_id = v_trade.author_id and item_id = v_item.item_id;
  end loop;

  for v_item in select item_id, quantity from trade_items where trade_id = p_trade_id and direction = 'oferecido' loop
    insert into inventory (player_id, item_id, quantity) values (v_recipient_id, v_item.item_id, v_item.quantity)
    on conflict (player_id, item_id) do update set quantity = inventory.quantity + v_item.quantity;
  end loop;

  for v_item in select item_id, quantity from trade_items where trade_id = p_trade_id and direction = 'pedido' loop
    update inventory set quantity = quantity - v_item.quantity where player_id = v_recipient_id and item_id = v_item.item_id;
  end loop;

  for v_item in select item_id, quantity from trade_items where trade_id = p_trade_id and direction = 'pedido' loop
    insert into inventory (player_id, item_id, quantity) values (v_trade.author_id, v_item.item_id, v_item.quantity)
    on conflict (player_id, item_id) do update set quantity = inventory.quantity + v_item.quantity;
  end loop;

  update trades set status = 'aceita' where id = p_trade_id;
  update profiles set reputation = reputation + 20 where id in (v_trade.author_id, v_recipient_id);

  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.cancel_trade(p_trade_id uuid)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_author_id uuid := auth.uid();
begin
  update trades set status = 'cancelada'
  where id = p_trade_id and author_id = v_author_id and status = 'pendente';

  if not found then
    raise exception 'Troca nao encontrada ou voce nao e o autor.';
  end if;

  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.confirm_alert(p_alert_id uuid)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_player_id uuid := auth.uid();
  v_author_id uuid;
  v_count int;
begin
  select author_id into v_author_id from horde_alerts where id = p_alert_id;

  if v_author_id is null then
    raise exception 'Alerta nao encontrado.';
  end if;

  if v_author_id = v_player_id then
    raise exception 'Voce nao pode confirmar o seu proprio alerta.';
  end if;

  insert into alert_confirmations (alert_id, player_id)
  values (p_alert_id, v_player_id)
  on conflict (alert_id, player_id) do nothing;

  select count(*) into v_count from alert_confirmations where alert_id = p_alert_id;

  if v_count >= 2 then
    update horde_alerts set reputation_granted = true
    where id = p_alert_id and reputation_granted = false;

    if found then
      update profiles set reputation = reputation + 25 where id = v_author_id;
    end if;
  end if;

  return jsonb_build_object('success', true, 'confirmations', v_count);
end;
$$;

create or replace function public.create_shelter(
  p_name text,
  p_description text,
  p_capacity int,
  p_photo_url text,
  p_latitude double precision,
  p_longitude double precision,
  p_visibility text default 'public'
)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_player_id uuid := auth.uid();
  v_shelter_id uuid;
begin
  insert into shelters (author_id, name, description, capacity, photo_url, latitude, longitude, visibility)
  values (v_player_id, p_name, p_description, p_capacity, p_photo_url, p_latitude, p_longitude, p_visibility)
  returning id into v_shelter_id;

  update profiles set reputation = reputation + 15 where id = v_player_id;

  return jsonb_build_object('success', true, 'shelter_id', v_shelter_id);
end;
$$;

-- ============================================================
-- 6. RLS (ROW LEVEL SECURITY)
-- ============================================================

alter table public.factions enable row level security;
create policy "factions_select_all" on public.factions for select using (true);

alter table public.profiles enable row level security;
create policy "profiles_select_all" on public.profiles for select using (true);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

alter table public.items enable row level security;
create policy "items_select_all" on public.items for select using (true);

alter table public.inventory enable row level security;
create policy "inventory_select_own" on public.inventory for select using (auth.uid() = player_id);

alter table public.shelters enable row level security;
create policy "shelters_select_visible" on public.shelters for select using (
  visibility = 'public'
  or (
    visibility = 'faction'
    and exists (
      select 1 from profiles
      where id = auth.uid()
        and faction_id = (select faction_id from profiles where id = shelters.author_id)
    )
  )
);
create policy "shelters_update_own" on public.shelters for update using (auth.uid() = author_id) with check (auth.uid() = author_id);
create policy "shelters_delete_own" on public.shelters for delete using (auth.uid() = author_id);

alter table public.expedition_types enable row level security;
create policy "expedition_types_select_all" on public.expedition_types for select using (true);

alter table public.expedition_rewards enable row level security;
create policy "expedition_rewards_select_all" on public.expedition_rewards for select using (true);

alter table public.expeditions enable row level security;
create policy "expeditions_select_own" on public.expeditions for select using (auth.uid() = player_id);

alter table public.trades enable row level security;
create policy "trades_select_involved" on public.trades for select using (auth.uid() = author_id or auth.uid() = recipient_id);

alter table public.trade_items enable row level security;
create policy "trade_items_select_involved" on public.trade_items for select using (
  exists (
    select 1 from trades
    where trades.id = trade_items.trade_id
      and (trades.author_id = auth.uid() or trades.recipient_id = auth.uid())
  )
);

alter table public.horde_alerts enable row level security;
create policy "horde_alerts_select_all" on public.horde_alerts for select using (expires_at > now());
create policy "horde_alerts_insert_own" on public.horde_alerts for insert with check (auth.uid() = author_id);

alter table public.alert_confirmations enable row level security;
create policy "alert_confirmations_select_own" on public.alert_confirmations for select using (auth.uid() = player_id);

-- ============================================================
-- 7. DADOS INICIAIS (SEED)
-- ============================================================

insert into public.factions (name, symbol, color, description) values
('Os Vigilantes', '🛡️', '#2E7D32', 'Defensores da ordem. Especialistas em abrigos e defesa.'),
('Os Nômades', '🏜️', '#F57C00', 'Exploradores incansáveis. Mestres em expedições e coleta.'),
('Os Tecnomantes', '⚙️', '#1565C0', 'Engenheiros da sobrevivência. Especialistas em ferramentas e trocas.');

insert into public.items (name, category, icon) values
('Água Purificada', 'água', 'water_drop'),
('Comida Enlatada', 'comida', 'restaurant'),
('Kit Médico', 'medicamentos', 'medical_services'),
('Pé de Cabra', 'ferramentas', 'construction'),
('Gasolina', 'combustível', 'local_gas_station');

insert into public.expedition_types (name, description, duration_seconds, risk) values
('Mercado Abandonado', 'Prateleiras esquecidas podem render mantimentos.', 60, 'baixo'),
('Hospital', 'Medicamentos valiosos, mas o risco de infecção é alto.', 180, 'médio'),
('Posto de Gasolina', 'Combustível e ferramentas, mas atrai hordas.', 300, 'alto');

insert into public.expedition_rewards (expedition_type_id, item_id, min_quantity, max_quantity)
select et.id, i.id, 1, 3 from expedition_types et, items i
where et.name = 'Mercado Abandonado' and i.name in ('Comida Enlatada', 'Água Purificada');

insert into public.expedition_rewards (expedition_type_id, item_id, min_quantity, max_quantity)
select et.id, i.id, 1, 2 from expedition_types et, items i
where et.name = 'Hospital' and i.name = 'Kit Médico';

insert into public.expedition_rewards (expedition_type_id, item_id, min_quantity, max_quantity)
select et.id, i.id, 1, 2 from expedition_types et, items i
where et.name = 'Posto de Gasolina' and i.name in ('Gasolina', 'Pé de Cabra');

-- ============================================================
-- 8. STORAGE
-- ============================================================

insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('shelters', 'shelters', true) on conflict (id) do nothing;

create policy "avatar_upload_own" on storage.objects for insert to authenticated with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid()::text));
create policy "avatar_read_all" on storage.objects for select using (bucket_id = 'avatars');
create policy "shelter_photo_upload" on storage.objects for insert to authenticated with check (bucket_id = 'shelters');
create policy "shelter_photo_read_all" on storage.objects for select using (bucket_id = 'shelters');

-- ============================================================
-- 9. REALTIME
-- ============================================================

alter publication supabase_realtime add table public.horde_alerts;
alter publication supabase_realtime add table public.trades;