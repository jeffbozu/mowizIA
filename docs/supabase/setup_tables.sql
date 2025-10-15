-- Script de configuración de tablas para Supabase MEYPARK
-- Ejecutar este script en el SQL Editor de Supabase

-- ========================================
-- 1. CREAR TABLAS PRINCIPALES
-- ========================================

-- Tabla companies
CREATE TABLE IF NOT EXISTS companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  primary_color TEXT DEFAULT '#E62144',
  background_color TEXT DEFAULT '#FFFFFF',
  logo_url TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

-- Tabla operators
CREATE TABLE IF NOT EXISTS operators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT DEFAULT 'operator' CHECK (role IN ('superadmin', 'admin', 'operator', 'viewer')),
  permissions JSONB DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

-- Tabla zones
CREATE TABLE IF NOT EXISTS zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#2196F3',
  price_per_hour DECIMAL(10,2) NOT NULL,
  max_duration INTEGER DEFAULT 240, -- minutos
  description TEXT,
  time_options JSONB DEFAULT '[15,30,60,120,180,240]',
  time_increment INTEGER DEFAULT 15,
  min_time INTEGER DEFAULT 15,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

-- Tabla payment_config
CREATE TABLE IF NOT EXISTS payment_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  accepted_coins JSONB DEFAULT '[0.05,0.10,0.20,0.50,1.00,2.00]',
  accepted_cards JSONB DEFAULT '["Visa","Mastercard"]',
  max_change_amount DECIMAL(10,2) DEFAULT 10.00,
  min_payment_amount DECIMAL(10,2) DEFAULT 0.15,
  currency TEXT DEFAULT 'EUR',
  currency_symbol TEXT DEFAULT '€',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla accessibility_config
CREATE TABLE IF NOT EXISTS accessibility_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  dark_mode BOOLEAN DEFAULT false,
  high_contrast BOOLEAN DEFAULT false,
  font_size TEXT DEFAULT 'normal' CHECK (font_size IN ('small', 'normal', 'large')),
  reduce_animations BOOLEAN DEFAULT false,
  voice_guide BOOLEAN DEFAULT false,
  voice_speed DECIMAL(3,2) DEFAULT 0.50,
  voice_pitch DECIMAL(3,2) DEFAULT 1.00,
  voice_volume DECIMAL(3,2) DEFAULT 0.80,
  adaptive_ai BOOLEAN DEFAULT false,
  simplified_mode BOOLEAN DEFAULT false,
  current_language TEXT DEFAULT 'es-ES',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla kiosks
CREATE TABLE IF NOT EXISTS kiosks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  operator_id UUID REFERENCES operators(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  location TEXT,
  gps_lat DECIMAL(10,8),
  gps_lng DECIMAL(11,8),
  status TEXT DEFAULT 'offline' CHECK (status IN ('online', 'offline', 'error', 'maintenance')),
  hardware_status JSONB DEFAULT '{}',
  current_screen TEXT,
  total_sessions INTEGER DEFAULT 0,
  today_income DECIMAL(10,2) DEFAULT 0.00,
  last_connection TIMESTAMP WITH TIME ZONE,
  last_error JSONB,
  version TEXT DEFAULT '1.0.0',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_app BOOLEAN DEFAULT false
);

-- Tabla active_sessions
CREATE TABLE IF NOT EXISTS active_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kiosk_id UUID REFERENCES kiosks(id) ON DELETE CASCADE,
  zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
  plate TEXT NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('cash', 'chip', 'contactless')),
  is_extend BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla invoice_config
CREATE TABLE IF NOT EXISTS invoice_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  company_name TEXT NOT NULL,
  cif TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  iva_rate DECIMAL(5,2) DEFAULT 21.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- 2. TABLAS DE UI DINÁMICA
-- ========================================

-- Tabla ui_texts
CREATE TABLE IF NOT EXISTS ui_texts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  screen TEXT NOT NULL, -- 'login', 'zone', 'payment', etc.
  element TEXT NOT NULL, -- 'title', 'button_next', 'error_invalid', etc.
  language TEXT NOT NULL DEFAULT 'es-ES',
  text_value TEXT NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(company_id, screen, element, language)
);

-- Tabla ui_translations_cache
CREATE TABLE IF NOT EXISTS ui_translations_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  language TEXT NOT NULL,
  translations_json JSONB NOT NULL,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(company_id, language)
);

-- Tabla ui_elements_config
CREATE TABLE IF NOT EXISTS ui_elements_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  screen TEXT NOT NULL,
  element_key TEXT NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  custom_properties JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(company_id, screen, element_key)
);

-- ========================================
-- 3. ÍNDICES PARA PERFORMANCE
-- ========================================

-- Índices para foreign keys
CREATE INDEX IF NOT EXISTS idx_operators_company_id ON operators(company_id);
CREATE INDEX IF NOT EXISTS idx_zones_company_id ON zones(company_id);
CREATE INDEX IF NOT EXISTS idx_kiosks_company_id ON kiosks(company_id);
CREATE INDEX IF NOT EXISTS idx_kiosks_operator_id ON kiosks(operator_id);
CREATE INDEX IF NOT EXISTS idx_active_sessions_kiosk_id ON active_sessions(kiosk_id);
CREATE INDEX IF NOT EXISTS idx_active_sessions_zone_id ON active_sessions(zone_id);
CREATE INDEX IF NOT EXISTS idx_payment_config_company_id ON payment_config(company_id);
CREATE INDEX IF NOT EXISTS idx_accessibility_config_company_id ON accessibility_config(company_id);
CREATE INDEX IF NOT EXISTS idx_invoice_config_company_id ON invoice_config(company_id);
CREATE INDEX IF NOT EXISTS idx_ui_texts_company_id ON ui_texts(company_id);
CREATE INDEX IF NOT EXISTS idx_ui_translations_cache_company_id ON ui_translations_cache(company_id);
CREATE INDEX IF NOT EXISTS idx_ui_elements_config_company_id ON ui_elements_config(company_id);

-- Índices para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_active_sessions_plate ON active_sessions(plate);
CREATE INDEX IF NOT EXISTS idx_active_sessions_end_time ON active_sessions(end_time);
CREATE INDEX IF NOT EXISTS idx_ui_texts_company_screen ON ui_texts(company_id, screen);
CREATE INDEX IF NOT EXISTS idx_ui_elements_company_screen ON ui_elements_config(company_id, screen);

-- Índices para filtros activos
CREATE INDEX IF NOT EXISTS idx_companies_active ON companies(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_zones_active ON zones(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_operators_active ON operators(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_kiosks_status ON kiosks(status);

-- ========================================
-- 4. FUNCIONES Y TRIGGERS
-- ========================================

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
DROP TRIGGER IF EXISTS update_companies_updated_at ON companies;
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_operators_updated_at ON operators;
CREATE TRIGGER update_operators_updated_at BEFORE UPDATE ON operators FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_zones_updated_at ON zones;
CREATE TRIGGER update_zones_updated_at BEFORE UPDATE ON zones FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payment_config_updated_at ON payment_config;
CREATE TRIGGER update_payment_config_updated_at BEFORE UPDATE ON payment_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_accessibility_config_updated_at ON accessibility_config;
CREATE TRIGGER update_accessibility_config_updated_at BEFORE UPDATE ON accessibility_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_kiosks_updated_at ON kiosks;
CREATE TRIGGER update_kiosks_updated_at BEFORE UPDATE ON kiosks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_active_sessions_updated_at ON active_sessions;
CREATE TRIGGER update_active_sessions_updated_at BEFORE UPDATE ON active_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_invoice_config_updated_at ON invoice_config;
CREATE TRIGGER update_invoice_config_updated_at BEFORE UPDATE ON invoice_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_ui_texts_updated_at ON ui_texts;
CREATE TRIGGER update_ui_texts_updated_at BEFORE UPDATE ON ui_texts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_ui_translations_cache_updated_at ON ui_translations_cache;
CREATE TRIGGER update_ui_translations_cache_updated_at BEFORE UPDATE ON ui_translations_cache FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_ui_elements_config_updated_at ON ui_elements_config;
CREATE TRIGGER update_ui_elements_config_updated_at BEFORE UPDATE ON ui_elements_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para invalidar caché de traducciones
CREATE OR REPLACE FUNCTION invalidate_translations_cache()
RETURNS TRIGGER AS $$
BEGIN
    -- Eliminar caché cuando cambian ui_texts
    DELETE FROM ui_translations_cache 
    WHERE company_id = COALESCE(NEW.company_id, OLD.company_id)
    AND language = COALESCE(NEW.language, OLD.language);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Trigger para invalidar caché
DROP TRIGGER IF EXISTS invalidate_cache_on_ui_texts_change ON ui_texts;
CREATE TRIGGER invalidate_cache_on_ui_texts_change
    AFTER INSERT OR UPDATE OR DELETE ON ui_texts
    FOR EACH ROW EXECUTE FUNCTION invalidate_translations_cache();

-- Función para regenerar caché de traducciones
CREATE OR REPLACE FUNCTION regenerate_translations_cache(p_company_id UUID, p_language TEXT)
RETURNS VOID AS $$
DECLARE
    translations_json JSONB;
BEGIN
    -- Generar JSON con todas las traducciones
    SELECT jsonb_object_agg(
        screen || '.' || element, 
        text_value
    ) INTO translations_json
    FROM ui_texts 
    WHERE company_id = p_company_id 
    AND language = p_language 
    AND is_enabled = true;
    
    -- Insertar o actualizar caché
    INSERT INTO ui_translations_cache (company_id, language, translations_json)
    VALUES (p_company_id, p_language, COALESCE(translations_json, '{}'::jsonb))
    ON CONFLICT (company_id, language) 
    DO UPDATE SET 
        translations_json = EXCLUDED.translations_json,
        last_updated = NOW();
END;
$$ language 'plpgsql';

-- ========================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ========================================

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

-- Políticas RLS básicas (permitir todo por ahora, se configurarán después)
CREATE POLICY "Enable all operations for all users" ON companies FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON operators FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON zones FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON payment_config FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON accessibility_config FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON kiosks FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON active_sessions FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON invoice_config FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON ui_texts FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON ui_translations_cache FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON ui_elements_config FOR ALL USING (true);

-- ========================================
-- 6. VISTAS OPTIMIZADAS
-- ========================================

-- Vista de empresa completa
CREATE OR REPLACE VIEW v_company_complete AS
SELECT 
    c.*,
    pc.accepted_coins,
    pc.accepted_cards,
    pc.max_change_amount,
    pc.min_payment_amount,
    pc.currency,
    pc.currency_symbol,
    ac.dark_mode,
    ac.high_contrast,
    ac.font_size,
    ac.reduce_animations,
    ac.voice_guide,
    ac.voice_speed,
    ac.voice_pitch,
    ac.voice_volume,
    ac.adaptive_ai,
    ac.simplified_mode,
    ac.current_language,
    ic.company_name as invoice_company_name,
    ic.cif,
    ic.address as invoice_address,
    ic.city,
    ic.postal_code,
    ic.email as invoice_email,
    ic.phone as invoice_phone,
    ic.iva_rate
FROM companies c
LEFT JOIN payment_config pc ON c.id = pc.company_id
LEFT JOIN accessibility_config ac ON c.id = ac.company_id
LEFT JOIN invoice_config ic ON c.id = ic.company_id
WHERE c.is_active = true;

-- Vista de zonas con empresa
CREATE OR REPLACE VIEW v_zones_with_company AS
SELECT 
    z.*,
    c.name as company_name,
    c.primary_color as company_primary_color
FROM zones z
JOIN companies c ON z.company_id = c.id
WHERE z.is_active = true AND c.is_active = true;

-- Vista de sesiones activas con detalles
CREATE OR REPLACE VIEW v_active_sessions_details AS
SELECT 
    s.*,
    z.name as zone_name,
    z.price_per_hour,
    c.name as company_name,
    k.name as kiosk_name,
    k.location as kiosk_location
FROM active_sessions s
JOIN zones z ON s.zone_id = z.id
JOIN companies c ON z.company_id = c.id
JOIN kiosks k ON s.kiosk_id = k.id
WHERE s.end_time > NOW();

-- ========================================
-- 7. CONFIGURACIÓN INICIAL
-- ========================================

-- Crear usuario superadmin por defecto
INSERT INTO companies (id, name, primary_color, background_color, contact_email, contact_phone, address)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'MOWIZ',
    '#E62144',
    '#FFFFFF',
    'info@mowiz.com',
    '+34 900 123 456',
    'Madrid, España'
) ON CONFLICT (id) DO NOTHING;

-- Crear operador superadmin
INSERT INTO operators (id, company_id, name, username, password_hash, role, permissions)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Super Admin',
    'superadmin',
    '$2b$10$rQZ8vQZ8vQZ8vQZ8vQZ8vO', -- Contraseña: admin123 (cambiar en producción)
    'superadmin',
    '["all"]'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- Crear configuración de pagos por defecto
INSERT INTO payment_config (company_id, accepted_coins, accepted_cards, max_change_amount, min_payment_amount, currency, currency_symbol)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    '[0.05,0.10,0.20,0.50,1.00,2.00]'::jsonb,
    '["Visa","Mastercard"]'::jsonb,
    10.00,
    0.15,
    'EUR',
    '€'
) ON CONFLICT DO NOTHING;

-- Crear configuración de accesibilidad por defecto
INSERT INTO accessibility_config (company_id, dark_mode, high_contrast, font_size, reduce_animations, voice_guide, voice_speed, voice_pitch, voice_volume, adaptive_ai, simplified_mode, current_language)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    false,
    false,
    'normal',
    false,
    false,
    0.50,
    1.00,
    0.80,
    false,
    false,
    'es-ES'
) ON CONFLICT DO NOTHING;

-- Crear configuración de facturación por defecto
INSERT INTO invoice_config (company_id, company_name, cif, address, city, postal_code, email, phone, iva_rate)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'MOWIZ S.L.',
    'B12345678',
    'Calle de la Innovación, 123',
    'Madrid',
    '28001',
    'facturacion@mowiz.com',
    '+34 900 123 456',
    21.00
) ON CONFLICT DO NOTHING;

-- ========================================
-- 8. MENSAJE DE CONFIRMACIÓN
-- ========================================

DO $$
BEGIN
    RAISE NOTICE '✅ Esquema de base de datos MEYPARK configurado correctamente';
    RAISE NOTICE '📊 Tablas creadas: companies, operators, zones, payment_config, accessibility_config, kiosks, active_sessions, invoice_config, ui_texts, ui_translations_cache, ui_elements_config';
    RAISE NOTICE '🔒 RLS habilitado en todas las tablas';
    RAISE NOTICE '⚡ Índices y triggers configurados';
    RAISE NOTICE '👁️ Vistas optimizadas creadas';
    RAISE NOTICE '👤 Usuario superadmin creado: username=superadmin, password=admin123';
    RAISE NOTICE '🏢 Empresa MOWIZ creada como principal';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 Próximo paso: Migrar datos existentes desde mock_data.json';
END $$;
