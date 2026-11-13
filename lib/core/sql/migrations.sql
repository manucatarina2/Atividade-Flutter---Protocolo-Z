-- ============================================================
-- Protocolo Z — migrations.sql
-- Execute no Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. HABILITAR REALTIME NAS TABELAS
-- ============================================================

-- Adiciona horde_alerts ao canal de publicação do Supabase Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE horde_alerts;

-- Adiciona trades ao canal de publicação do Supabase Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE trades;

-- ============================================================
-- 2. ROW LEVEL SECURITY (RLS)
-- ============================================================

-- ---- HORDE ALERTS ----
ALTER TABLE horde_alerts ENABLE ROW LEVEL SECURITY;

-- Todos os usuários autenticados podem ler alertas de horda
CREATE POLICY "horde_alerts_select_all"
  ON horde_alerts
  FOR SELECT
  TO authenticated
  USING (true);

-- Usuários autenticados podem inserir alertas
CREATE POLICY "horde_alerts_insert_own"
  ON horde_alerts
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- ---- SHELTERS ----
ALTER TABLE shelters ENABLE ROW LEVEL SECURITY;

-- Todos os usuários autenticados podem ver abrigos públicos ou da sua facção
CREATE POLICY "shelters_select_all"
  ON shelters
  FOR SELECT
  TO authenticated
  USING (true);

-- Usuários autenticados podem criar abrigos
CREATE POLICY "shelters_insert_own"
  ON shelters
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- Dono do abrigo pode atualizar
CREATE POLICY "shelters_update_own"
  ON shelters
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by);

-- ---- TRADES ----
ALTER TABLE trades ENABLE ROW LEVEL SECURITY;

-- Usuário pode ver trades onde é remetente ou destinatário
CREATE POLICY "trades_select_own"
  ON trades
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = from_user_id OR auth.uid() = to_user_id
  );

-- Usuários autenticados podem criar trades
CREATE POLICY "trades_insert_own"
  ON trades
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = from_user_id);

-- Destinatário pode atualizar status (aceitar/recusar)
CREATE POLICY "trades_update_participant"
  ON trades
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = from_user_id OR auth.uid() = to_user_id
  );

-- ---- TRADE ITEMS ----
ALTER TABLE trade_items ENABLE ROW LEVEL SECURITY;

-- Participantes da trade podem ver os itens
CREATE POLICY "trade_items_select_participant"
  ON trade_items
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM trades t
      WHERE t.id = trade_items.trade_id
        AND (t.from_user_id = auth.uid() OR t.to_user_id = auth.uid())
    )
  );

-- Usuários autenticados podem inserir itens em trades que criaram
CREATE POLICY "trade_items_insert_own"
  ON trade_items
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM trades t
      WHERE t.id = trade_items.trade_id
        AND t.from_user_id = auth.uid()
    )
  );
