# Esquema de Base de Datos Supabase - MEYPARK

## Visión General

Este documento describe el esquema completo de la base de datos Supabase para el sistema MEYPARK. Todas las tablas están diseñadas para soportar múltiples empresas con configuración independiente y sincronización en tiempo real.

## Diagrama de Relaciones

```
companies (1) ──→ (N) operators
companies (1) ──→ (N) zones
companies (1) ──→ (1) payment_config
companies (1) ──→ (1) accessibility_config
companies (1) ──→ (1) invoice_config
companies (1) ──→ (N) kiosks
companies (1) ──→ (N) ui_texts
companies (1) ──→ (N) ui_translations_cache
companies (1) ──→ (N) ui_elements_config

operators (1) ──→ (N) kiosks
zones (1) ──→ (N) active_sessions
kiosks (1) ──→ (N) active_sessions
```

## Tablas Principales

### 1. companies
**Propósito**: Almacena información de empresas con configuración de branding

```sql
CREATE TABLE companies (
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
```

**Campos**:
- `id`: Identificador único de la empresa
- `name`: Nombre de la empresa (ej: "MOWIZ", "EYPSA")
- `primary_color`: Color principal en formato hex (ej: "#E62144")
- `background_color`: Color de fondo en formato hex
- `logo_url`: URL del logo (Supabase Storage)
- `contact_email`: Email de contacto
- `contact_phone`: Teléfono de contacto
- `address`: Dirección física
- `is_active`: Si la empresa está activa

### 2. operators
**Propósito**: Usuarios/operadores del sistema con roles y permisos

```sql
CREATE TABLE operators (
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
```

**Campos**:
- `id`: Identificador único del operador
- `company_id`: Referencia a la empresa
- `name`: Nombre completo del operador
- `username`: Usuario único para login
- `password_hash`: Contraseña hasheada con bcrypt
- `role`: Rol del usuario (superadmin, admin, operator, viewer)
- `permissions`: Permisos granulares en formato JSON

### 3. zones
**Propósito**: Zonas de estacionamiento con motor de tarifas

```sql
CREATE TABLE zones (
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
```

**Campos**:
- `id`: Identificador único de la zona
- `company_id`: Referencia a la empresa
- `name`: Nombre de la zona (ej: "Coche", "Moto", "Azul")
- `color`: Color de la zona en formato hex
- `price_per_hour`: Precio por hora en euros
- `max_duration`: Duración máxima en minutos
- `time_options`: Opciones de tiempo disponibles [15,30,60,120,180,240]
- `time_increment`: Incremento mínimo de tiempo
- `min_time`: Tiempo mínimo permitido

### 4. payment_config
**Propósito**: Configuración de pagos por empresa

```sql
CREATE TABLE payment_config (
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
```

### 5. accessibility_config
**Propósito**: Configuración de accesibilidad por empresa

```sql
CREATE TABLE accessibility_config (
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
```

### 6. kiosks
**Propósito**: Kioscos/dispositivos físicos y apps

```sql
CREATE TABLE kiosks (
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
```

### 7. active_sessions
**Propósito**: Sesiones de estacionamiento activas

```sql
CREATE TABLE active_sessions (
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
```

### 8. invoice_config
**Propósito**: Configuración de facturación por empresa

```sql
CREATE TABLE invoice_config (
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
```

## Tablas de UI Dinámica

### 9. ui_texts
**Propósito**: Textos de UI personalizables por empresa e idioma

```sql
CREATE TABLE ui_texts (
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
```

### 10. ui_translations_cache
**Propósito**: Caché JSON de traducciones para performance

```sql
CREATE TABLE ui_translations_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  language TEXT NOT NULL,
  translations_json JSONB NOT NULL,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(company_id, language)
);
```

### 11. ui_elements_config
**Propósito**: Configuración de elementos UI (habilitar/deshabilitar botones)

```sql
CREATE TABLE ui_elements_config (
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
```

## Índices y Optimizaciones

```sql
-- Índices para performance
CREATE INDEX idx_operators_company_id ON operators(company_id);
CREATE INDEX idx_zones_company_id ON zones(company_id);
CREATE INDEX idx_kiosks_company_id ON kiosks(company_id);
CREATE INDEX idx_active_sessions_plate ON active_sessions(plate);
CREATE INDEX idx_active_sessions_kiosk_id ON active_sessions(kiosk_id);
CREATE INDEX idx_ui_texts_company_screen ON ui_texts(company_id, screen);
CREATE INDEX idx_ui_elements_company_screen ON ui_elements_config(company_id, screen);

-- Índices para búsquedas frecuentes
CREATE INDEX idx_companies_active ON companies(is_active) WHERE is_active = true;
CREATE INDEX idx_zones_active ON zones(is_active) WHERE is_active = true;
CREATE INDEX idx_operators_active ON operators(is_active) WHERE is_active = true;
```

## Funciones y Triggers

### Función para actualizar updated_at

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger a todas las tablas
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_operators_updated_at BEFORE UPDATE ON operators FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_zones_updated_at BEFORE UPDATE ON zones FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_config_updated_at BEFORE UPDATE ON payment_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_accessibility_config_updated_at BEFORE UPDATE ON accessibility_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_kiosks_updated_at BEFORE UPDATE ON kiosks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_active_sessions_updated_at BEFORE UPDATE ON active_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoice_config_updated_at BEFORE UPDATE ON invoice_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ui_texts_updated_at BEFORE UPDATE ON ui_texts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ui_translations_cache_updated_at BEFORE UPDATE ON ui_translations_cache FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ui_elements_config_updated_at BEFORE UPDATE ON ui_elements_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Función para invalidar caché de traducciones

```sql
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

CREATE TRIGGER invalidate_cache_on_ui_texts_change
    AFTER INSERT OR UPDATE OR DELETE ON ui_texts
    FOR EACH ROW EXECUTE FUNCTION invalidate_translations_cache();
```

### Función para regenerar caché de traducciones

```sql
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
```

## Row Level Security (RLS)

### Habilitar RLS en todas las tablas

```sql
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
```

### Políticas RLS básicas

```sql
-- Política para que cada empresa solo vea sus datos
CREATE POLICY "Users can only see their company data" ON companies
    FOR ALL USING (id = (SELECT company_id FROM operators WHERE username = current_setting('app.current_user', true)));

-- Política para operadores
CREATE POLICY "Users can only see operators from their company" ON operators
    FOR ALL USING (company_id = (SELECT company_id FROM operators WHERE username = current_setting('app.current_user', true)));

-- Política para zonas
CREATE POLICY "Users can only see zones from their company" ON zones
    FOR ALL USING (company_id = (SELECT company_id FROM operators WHERE username = current_setting('app.current_user', true)));

-- Política para superadmin (ve todo)
CREATE POLICY "Superadmin can see all data" ON companies
    FOR ALL USING ((SELECT role FROM operators WHERE username = current_setting('app.current_user', true)) = 'superadmin');
```

## Vistas Optimizadas

### Vista de empresa completa

```sql
CREATE VIEW v_company_complete AS
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
```

### Vista de zonas con empresa

```sql
CREATE VIEW v_zones_with_company AS
SELECT 
    z.*,
    c.name as company_name,
    c.primary_color as company_primary_color
FROM zones z
JOIN companies c ON z.company_id = c.id
WHERE z.is_active = true AND c.is_active = true;
```

### Vista de sesiones activas con detalles

```sql
CREATE VIEW v_active_sessions_details AS
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
```

## Ejemplos de Uso

### Obtener configuración completa de una empresa

```sql
SELECT * FROM v_company_complete WHERE id = 'company-uuid';
```

### Obtener traducciones de una empresa

```sql
SELECT screen, element, text_value 
FROM ui_texts 
WHERE company_id = 'company-uuid' 
AND language = 'es-ES' 
AND is_enabled = true
ORDER BY screen, element;
```

### Obtener zonas activas de una empresa

```sql
SELECT * FROM v_zones_with_company 
WHERE company_id = 'company-uuid'
ORDER BY name;
```

### Obtener sesiones activas por matrícula

```sql
SELECT * FROM v_active_sessions_details 
WHERE plate = '1234ABC';
```

## Notas de Implementación

1. **UUIDs**: Todas las tablas usan UUIDs como claves primarias para mejor distribución y seguridad
2. **Timestamps**: Uso de `TIMESTAMP WITH TIME ZONE` para manejo correcto de zonas horarias
3. **JSONB**: Uso extensivo de JSONB para campos flexibles como permisos, configuraciones, etc.
4. **Constraints**: Validaciones a nivel de base de datos para mantener integridad
5. **Índices**: Índices optimizados para consultas frecuentes
6. **RLS**: Seguridad a nivel de fila para multi-tenancy
7. **Triggers**: Automatización de tareas como actualización de timestamps y invalidación de caché
8. **Vistas**: Vistas optimizadas para consultas complejas frecuentes

---

## 🔐 Sistema de Permisos

### Tabla: **user_roles**
```sql
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  company_id UUID REFERENCES companies(id),
  role_name VARCHAR(20) NOT NULL CHECK (role_name IN ('superadmin', 'admin', 'operator', 'viewer')),
  permissions JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Tabla: **permission_templates**
```sql
CREATE TABLE permission_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_name VARCHAR(20) NOT NULL,
  resource_type VARCHAR(50) NOT NULL,
  actions JSONB NOT NULL,
  conditions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Tabla: **audit_logs**
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 📊 Vistas Optimizadas

### Vista: **v_company_complete**
- Empresa con toda su configuración y estadísticas
- Incluye: payment_config, accessibility_config, invoice_config
- Estadísticas: operadores, zonas, kioscos, sesiones activas

### Vista: **v_zones_with_company**
- Zonas con información de empresa y estadísticas
- Incluye: sesiones activas, ingresos del día, promedio de precios

### Vista: **v_active_sessions_details**
- Sesiones activas con detalles completos
- Incluye: cálculos de tiempo, estado, tipo de sesión

### Vista: **v_kiosks_status**
- Estado completo de kioscos
- Incluye: estado de conexión, estadísticas del día

### Vista: **v_company_stats**
- Estadísticas agregadas por empresa
- Incluye: estadísticas de operadores, zonas, kioscos, sesiones

### Vista: **v_daily_income_summary**
- Resumen de ingresos por día y empresa
- Incluye: sesiones por método de pago, sesiones extendidas

### Vista: **v_top_zones_by_income**
- Top zonas ordenadas por ingresos
- Incluye: estadísticas de hoy, semana, mes

### Vista: **v_operators_with_stats**
- Operadores con sus estadísticas
- Incluye: kiosco asignado, sesiones gestionadas

### Vista: **v_ui_config_by_company**
- Configuración completa de UI por empresa
- Incluye: textos, elementos, caché de traducciones

## ⚡ Edge Functions

### 1. **manage-sessions**
- Gestión completa de sesiones de estacionamiento
- Acciones: add, search, extend, update, remove
- Endpoint: `/functions/v1/manage-sessions`

### 2. **generate-invoice**
- Generación de facturas electrónicas
- Crea PDFs y los almacena en Supabase Storage
- Endpoint: `/functions/v1/generate-invoice`

### 3. **dashboard-api**
- API para dashboard y estadísticas
- Proporciona datos agregados en tiempo real
- Endpoint: `/functions/v1/dashboard-api`

### 4. **control-center**
- API para Centro de Control
- Acciones: get_company_stats, create_company, sync_company_data
- Endpoint: `/functions/v1/control-center`

## 🔧 Funciones de Utilidad

### 1. **check_permission(user_id, resource_type, action, resource_company_id)**
- Verifica permisos de usuario para un recurso específico
- Retorna: BOOLEAN

### 2. **get_current_user_info()**
- Obtiene información del usuario actual
- Retorna: user_id, role_name, company_id, company_name

### 3. **update_updated_at()**
- Actualiza automáticamente el campo updated_at
- Se ejecuta en triggers

### 4. **invalidate_translations_cache()**
- Invalida caché de traducciones cuando cambian ui_texts
- Se ejecuta en triggers

## 📋 Ejemplos de Uso

### Crear Nueva Empresa
```sql
-- 1. Crear empresa
INSERT INTO companies (id, name, primary_color, is_active)
VALUES ('nueva-empresa', 'Mi Nueva Empresa', '#00FF00', true);

-- 2. Crear operador admin
INSERT INTO operators (company_id, name, username, password_hash, role)
VALUES ('nueva-empresa', 'Admin', 'admin', '$2b$10$...', 'admin');

-- 3. Crear zona
INSERT INTO zones (company_id, name, price_per_hour, is_active)
VALUES ('nueva-empresa', 'Zona Centro', 2.50, true);

-- 4. Crear configuraciones
INSERT INTO payment_config (company_id, currency, currency_symbol)
VALUES ('nueva-empresa', 'EUR', '€');
```

### Cambiar Tarifa de Zona
```sql
UPDATE zones 
SET price_per_hour = 3.00 
WHERE id = 'zona-1';
-- El cambio se aplica automáticamente en la app en < 2 segundos
```

### Personalizar Texto de Botón
```sql
UPDATE ui_texts 
SET text_value = 'Procesar Pago' 
WHERE company_id = 'mowiz' 
  AND screen = 'payment' 
  AND element = 'pay_button' 
  AND language = 'es-ES';
-- El texto se actualiza automáticamente en la app
```

### Deshabilitar Botón
```sql
UPDATE ui_elements_config 
SET is_enabled = false 
WHERE company_id = 'mowiz' 
  AND screen = 'home' 
  AND element_key = 'accessibility_button';
-- El botón desaparece de la pantalla
```

### Obtener Estadísticas de Empresa
```sql
SELECT * FROM v_company_stats WHERE company_id = 'mowiz';
```

### Ver Sesiones Activas
```sql
SELECT * FROM v_active_sessions_details WHERE company_id = 'mowiz';
```

### Exportar Datos de Empresa
```sql
-- Usar Edge Function control-center
POST /functions/v1/control-center
{
  "action": "export_company_data",
  "data": { "company_id": "mowiz" }
}
```

## 🚀 Scripts de Utilidad

### 1. **test_realtime_sync.dart**
- Prueba sincronización en tiempo real
- Verifica cambios de tarifas, textos, colores

### 2. **test_offline_mode.dart**
- Prueba funcionamiento sin conexión
- Verifica datos en caché local

### 3. **test_edge_functions.dart**
- Prueba todas las Edge Functions
- Verifica salud del sistema

### 4. **backup_supabase.dart**
- Hace backup completo de datos
- Exporta todas las tablas a JSON

### 5. **sync_translations.dart**
- Sincroniza traducciones entre empresas
- Regenera caché de traducciones

## 📊 Monitoreo y Logs

### Logs de Aplicación
- **API**: Llamadas a la base de datos
- **Auth**: Autenticación de usuarios
- **Edge Functions**: Funciones del servidor
- **Realtime**: Sincronización en tiempo real

### Métricas del Dashboard
- **Active Users**: Usuarios activos
- **API Requests**: Peticiones a la API
- **Database Size**: Tamaño de la base de datos
- **Storage**: Uso de almacenamiento

### Auditoría
- Todos los cambios se registran en `audit_logs`
- Incluye: usuario, acción, recurso, valores antiguos/nuevos
- Timestamp y información de sesión

---

**¡El esquema está listo para el Centro de Control!** 🎯
