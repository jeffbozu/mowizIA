-- Crear tablas principales para MEYPARK

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
  username TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT DEFAULT 'operator',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(company_id, username)
);

-- Tabla zones
CREATE TABLE IF NOT EXISTS zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  price_per_hour DECIMAL(10,2) NOT NULL,
  max_hours INTEGER DEFAULT 8,
  time_options JSONB DEFAULT '["1", "2", "3", "4", "5", "6", "7", "8"]'::jsonb,
  time_increment INTEGER DEFAULT 1,
  min_time INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla payment_config
CREATE TABLE IF NOT EXISTS payment_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  accepted_coins JSONB DEFAULT '["0.50", "1.00", "2.00", "5.00"]'::jsonb,
  min_payment DECIMAL(10,2) DEFAULT 0.50,
  max_payment DECIMAL(10,2) DEFAULT 100.00,
  payment_methods JSONB DEFAULT '["cash", "card"]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla accessibility_config
CREATE TABLE IF NOT EXISTS accessibility_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  dark_mode BOOLEAN DEFAULT false,
  high_contrast BOOLEAN DEFAULT false,
  font_size TEXT DEFAULT 'medium',
  voice_guide BOOLEAN DEFAULT true,
  adaptive_ai BOOLEAN DEFAULT false,
  simplified_mode BOOLEAN DEFAULT false,
  reduce_animations BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla kiosks
CREATE TABLE IF NOT EXISTS kiosks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  location TEXT,
  status TEXT DEFAULT 'active',
  last_heartbeat TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla active_sessions
CREATE TABLE IF NOT EXISTS active_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
  plate TEXT NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  total_price DECIMAL(10,2),
  payment_method TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla invoice_config
CREATE TABLE IF NOT EXISTS invoice_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  tax_id TEXT,
  address TEXT,
  phone TEXT,
  email TEXT,
  logo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla ui_texts
CREATE TABLE IF NOT EXISTS ui_texts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  screen TEXT NOT NULL,
  element_key TEXT NOT NULL,
  text_value TEXT NOT NULL,
  language TEXT DEFAULT 'es-ES',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(company_id, screen, element_key, language)
);

-- Tabla ui_translations_cache
CREATE TABLE IF NOT EXISTS ui_translations_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  language TEXT NOT NULL,
  translations JSONB NOT NULL,
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
  is_visible BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(company_id, screen, element_key)
);
