-- Configurar Row Level Security (RLS) para todas las tablas

-- Habilitar RLS en todas las tablas
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE operators ENABLE ROW LEVEL SECURITY;
ALTER TABLE zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE accessibility_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE kiosks ENABLE ROW LEVEL SECURITY;
ALTER TABLE active_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE ui_texts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ui_translations_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE ui_elements_config ENABLE ROW LEVEL SECURITY;

-- Políticas para companies (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON companies
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON companies
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON companies
    FOR UPDATE USING (true);

-- Políticas para operators (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON operators
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON operators
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON operators
    FOR UPDATE USING (true);

-- Políticas para zones (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON zones
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON zones
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON zones
    FOR UPDATE USING (true);

-- Políticas para payment_config (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON payment_config
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON payment_config
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON payment_config
    FOR UPDATE USING (true);

-- Políticas para accessibility_config (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON accessibility_config
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON accessibility_config
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON accessibility_config
    FOR UPDATE USING (true);

-- Políticas para kiosks (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON kiosks
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON kiosks
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON kiosks
    FOR UPDATE USING (true);

-- Políticas para active_sessions (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON active_sessions
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON active_sessions
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON active_sessions
    FOR UPDATE USING (true);

-- Políticas para invoice_config (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON invoice_config
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON invoice_config
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON invoice_config
    FOR UPDATE USING (true);

-- Políticas para ui_texts (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON ui_texts
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON ui_texts
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON ui_texts
    FOR UPDATE USING (true);

-- Políticas para ui_translations_cache (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON ui_translations_cache
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON ui_translations_cache
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON ui_translations_cache
    FOR UPDATE USING (true);

-- Políticas para ui_elements_config (acceso público para lectura)
CREATE POLICY "Enable read access for all users" ON ui_elements_config
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON ui_elements_config
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON ui_elements_config
    FOR UPDATE USING (true);
