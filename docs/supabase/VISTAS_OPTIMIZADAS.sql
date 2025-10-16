-- Vistas Optimizadas para Centro de Control MEYPARK
-- Estas vistas proporcionan datos agregados y optimizados para el dashboard

-- ========================================
-- VISTA: Empresa Completa con Configuración
-- ========================================
CREATE OR REPLACE VIEW v_company_complete AS
SELECT 
  c.id,
  c.name,
  c.primary_color,
  c.background_color,
  c.logo_url,
  c.contact_email,
  c.phone,
  c.address,
  c.is_active,
  c.created_at,
  c.updated_at,
  
  -- Configuración de pagos
  pc.accepted_coins,
  pc.accepted_cards,
  pc.max_change_amount,
  pc.min_payment_amount,
  pc.currency,
  pc.currency_symbol,
  
  -- Configuración de accesibilidad
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
  
  -- Configuración de facturación
  ic.company_name as invoice_company_name,
  ic.cif,
  ic.address as invoice_address,
  ic.city,
  ic.postal_code,
  ic.email as invoice_email,
  ic.phone as invoice_phone,
  ic.iva_rate,
  
  -- Estadísticas
  (SELECT COUNT(*) FROM operators o WHERE o.company_id = c.id AND o.is_active = true) as total_operators,
  (SELECT COUNT(*) FROM zones z WHERE z.company_id = c.id AND z.is_active = true) as total_zones,
  (SELECT COUNT(*) FROM kiosks k WHERE k.company_id = c.id AND k.is_active = true) as total_kiosks,
  (SELECT COUNT(*) FROM active_sessions a WHERE a.company_id = c.id) as active_sessions_count
  
FROM companies c
LEFT JOIN payment_config pc ON c.id = pc.company_id
LEFT JOIN accessibility_config ac ON c.id = ac.company_id
LEFT JOIN invoice_config ic ON c.id = ic.company_id;

-- ========================================
-- VISTA: Zonas con Información de Empresa
-- ========================================
CREATE OR REPLACE VIEW v_zones_with_company AS
SELECT 
  z.id,
  z.company_id,
  c.name as company_name,
  c.primary_color as company_color,
  z.name as zone_name,
  z.color,
  z.price_per_hour,
  z.max_duration,
  z.description,
  z.time_options,
  z.time_increment,
  z.min_time,
  z.is_active,
  z.created_at,
  z.updated_at,
  
  -- Estadísticas de la zona
  (SELECT COUNT(*) FROM active_sessions a WHERE a.zone_id = z.id) as active_sessions,
  (SELECT COUNT(*) FROM active_sessions a WHERE a.zone_id = z.id AND a.start_time >= CURRENT_DATE) as today_sessions,
  (SELECT COALESCE(SUM(a.total_price), 0) FROM active_sessions a WHERE a.zone_id = z.id AND a.start_time >= CURRENT_DATE) as today_income,
  (SELECT COALESCE(AVG(a.total_price), 0) FROM active_sessions a WHERE a.zone_id = z.id AND a.start_time >= CURRENT_DATE) as avg_session_price
  
FROM zones z
JOIN companies c ON z.company_id = c.id;

-- ========================================
-- VISTA: Sesiones Activas con Detalles Completos
-- ========================================
CREATE OR REPLACE VIEW v_active_sessions_details AS
SELECT 
  a.id,
  a.kiosk_id,
  k.name as kiosk_name,
  k.location as kiosk_location,
  a.zone_id,
  z.name as zone_name,
  z.price_per_hour,
  c.name as company_name,
  c.primary_color as company_color,
  a.plate,
  a.start_time,
  a.end_time,
  a.total_price,
  a.payment_method,
  a.is_extend,
  a.created_at,
  a.updated_at,
  
  -- Cálculos de tiempo
  EXTRACT(EPOCH FROM (a.end_time - a.start_time)) / 60 as duration_minutes,
  EXTRACT(EPOCH FROM (a.end_time - NOW())) / 60 as remaining_minutes,
  CASE 
    WHEN a.end_time > NOW() THEN 'active'
    WHEN a.end_time <= NOW() THEN 'expired'
    ELSE 'unknown'
  END as status,
  
  -- Información de extensión
  CASE 
    WHEN a.is_extend THEN 'extended'
    ELSE 'new'
  END as session_type
  
FROM active_sessions a
LEFT JOIN kiosks k ON a.kiosk_id = k.id
LEFT JOIN zones z ON a.zone_id = z.id
LEFT JOIN companies c ON z.company_id = c.id;

-- ========================================
-- VISTA: Estado Completo de Kioscos
-- ========================================
CREATE OR REPLACE VIEW v_kiosks_status AS
SELECT 
  k.id,
  k.company_id,
  c.name as company_name,
  c.primary_color as company_color,
  k.operator_id,
  o.name as operator_name,
  k.name as kiosk_name,
  k.location,
  k.gps_lat,
  k.gps_lng,
  k.status,
  k.hardware_status,
  k.current_screen,
  k.total_sessions,
  k.today_income,
  k.last_connection,
  k.last_error,
  k.version,
  k.is_app,
  k.created_at,
  k.updated_at,
  
  -- Estadísticas del día
  (SELECT COUNT(*) FROM active_sessions a WHERE a.kiosk_id = k.id AND a.start_time >= CURRENT_DATE) as today_sessions,
  (SELECT COALESCE(SUM(a.total_price), 0) FROM active_sessions a WHERE a.kiosk_id = k.id AND a.start_time >= CURRENT_DATE) as today_income_calculated,
  
  -- Estado de conexión
  CASE 
    WHEN k.last_connection > NOW() - INTERVAL '5 minutes' THEN 'online'
    WHEN k.last_connection > NOW() - INTERVAL '1 hour' THEN 'warning'
    ELSE 'offline'
  END as connection_status,
  
  -- Tiempo desde última conexión
  EXTRACT(EPOCH FROM (NOW() - k.last_connection)) / 60 as minutes_since_last_connection
  
FROM kiosks k
LEFT JOIN companies c ON k.company_id = c.id
LEFT JOIN operators o ON k.operator_id = o.id;

-- ========================================
-- VISTA: Estadísticas por Empresa
-- ========================================
CREATE OR REPLACE VIEW v_company_stats AS
SELECT 
  c.id as company_id,
  c.name as company_name,
  c.primary_color,
  c.is_active,
  
  -- Estadísticas de operadores
  (SELECT COUNT(*) FROM operators o WHERE o.company_id = c.id AND o.is_active = true) as total_operators,
  (SELECT COUNT(*) FROM operators o WHERE o.company_id = c.id AND o.is_active = true AND o.role = 'admin') as admin_count,
  (SELECT COUNT(*) FROM operators o WHERE o.company_id = c.id AND o.is_active = true AND o.role = 'operator') as operator_count,
  
  -- Estadísticas de zonas
  (SELECT COUNT(*) FROM zones z WHERE z.company_id = c.id AND z.is_active = true) as total_zones,
  (SELECT COALESCE(AVG(z.price_per_hour), 0) FROM zones z WHERE z.company_id = c.id AND z.is_active = true) as avg_zone_price,
  
  -- Estadísticas de kioscos
  (SELECT COUNT(*) FROM kiosks k WHERE k.company_id = c.id AND k.is_active = true) as total_kiosks,
  (SELECT COUNT(*) FROM kiosks k WHERE k.company_id = c.id AND k.is_active = true AND k.status = 'active') as active_kiosks,
  
  -- Estadísticas de sesiones (hoy)
  (SELECT COUNT(*) FROM active_sessions a WHERE a.company_id = c.id AND a.start_time >= CURRENT_DATE) as today_sessions,
  (SELECT COALESCE(SUM(a.total_price), 0) FROM active_sessions a WHERE a.company_id = c.id AND a.start_time >= CURRENT_DATE) as today_income,
  (SELECT COALESCE(AVG(a.total_price), 0) FROM active_sessions a WHERE a.company_id = c.id AND a.start_time >= CURRENT_DATE) as avg_session_price,
  
  -- Estadísticas de sesiones (esta semana)
  (SELECT COUNT(*) FROM active_sessions a WHERE a.company_id = c.id AND a.start_time >= CURRENT_DATE - INTERVAL '7 days') as week_sessions,
  (SELECT COALESCE(SUM(a.total_price), 0) FROM active_sessions a WHERE a.company_id = c.id AND a.start_time >= CURRENT_DATE - INTERVAL '7 days') as week_income,
  
  -- Estadísticas de sesiones (este mes)
  (SELECT COUNT(*) FROM active_sessions a WHERE a.company_id = c.id AND a.start_time >= DATE_TRUNC('month', CURRENT_DATE)) as month_sessions,
  (SELECT COALESCE(SUM(a.total_price), 0) FROM active_sessions a WHERE a.company_id = c.id AND a.start_time >= DATE_TRUNC('month', CURRENT_DATE)) as month_income
  
FROM companies c;

-- ========================================
-- VISTA: Resumen de Ingresos por Día
-- ========================================
CREATE OR REPLACE VIEW v_daily_income_summary AS
SELECT 
  DATE(a.start_time) as date,
  c.id as company_id,
  c.name as company_name,
  COUNT(*) as total_sessions,
  COALESCE(SUM(a.total_price), 0) as total_income,
  COALESCE(AVG(a.total_price), 0) as avg_session_price,
  COUNT(CASE WHEN a.payment_method = 'cash' THEN 1 END) as cash_sessions,
  COUNT(CASE WHEN a.payment_method = 'chip_pin' THEN 1 END) as chip_pin_sessions,
  COUNT(CASE WHEN a.payment_method = 'contactless' THEN 1 END) as contactless_sessions,
  COUNT(CASE WHEN a.is_extend THEN 1 END) as extended_sessions,
  COUNT(CASE WHEN NOT a.is_extend THEN 1 END) as new_sessions
FROM active_sessions a
LEFT JOIN zones z ON a.zone_id = z.id
LEFT JOIN companies c ON z.company_id = c.id
GROUP BY DATE(a.start_time), c.id, c.name
ORDER BY date DESC, c.name;

-- ========================================
-- VISTA: Top Zonas por Ingresos
-- ========================================
CREATE OR REPLACE VIEW v_top_zones_by_income AS
SELECT 
  z.id as zone_id,
  z.name as zone_name,
  c.id as company_id,
  c.name as company_name,
  z.price_per_hour,
  COUNT(*) as total_sessions,
  COALESCE(SUM(a.total_price), 0) as total_income,
  COALESCE(AVG(a.total_price), 0) as avg_session_price,
  COUNT(CASE WHEN a.start_time >= CURRENT_DATE THEN 1 END) as today_sessions,
  COALESCE(SUM(CASE WHEN a.start_time >= CURRENT_DATE THEN a.total_price ELSE 0 END), 0) as today_income,
  COUNT(CASE WHEN a.start_time >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as week_sessions,
  COALESCE(SUM(CASE WHEN a.start_time >= CURRENT_DATE - INTERVAL '7 days' THEN a.total_price ELSE 0 END), 0) as week_income
FROM zones z
LEFT JOIN companies c ON z.company_id = c.id
LEFT JOIN active_sessions a ON z.id = a.zone_id
WHERE z.is_active = true
GROUP BY z.id, z.name, c.id, c.name, z.price_per_hour
ORDER BY total_income DESC;

-- ========================================
-- VISTA: Operadores con Estadísticas
-- ========================================
CREATE OR REPLACE VIEW v_operators_with_stats AS
SELECT 
  o.id,
  o.company_id,
  c.name as company_name,
  o.name as operator_name,
  o.username,
  o.role,
  o.is_active,
  o.created_at,
  o.updated_at,
  
  -- Estadísticas del operador
  (SELECT COUNT(*) FROM active_sessions a WHERE a.operator_id = o.id) as total_sessions_managed,
  (SELECT COUNT(*) FROM active_sessions a WHERE a.operator_id = o.id AND a.start_time >= CURRENT_DATE) as today_sessions,
  (SELECT COALESCE(SUM(a.total_price), 0) FROM active_sessions a WHERE a.operator_id = o.id AND a.start_time >= CURRENT_DATE) as today_income,
  
  -- Kiosco asignado
  k.id as kiosk_id,
  k.name as kiosk_name,
  k.location as kiosk_location,
  k.status as kiosk_status
  
FROM operators o
LEFT JOIN companies c ON o.company_id = c.id
LEFT JOIN kiosks k ON o.id = k.operator_id;

-- ========================================
-- VISTA: Configuración de UI por Empresa
-- ========================================
CREATE OR REPLACE VIEW v_ui_config_by_company AS
SELECT 
  c.id as company_id,
  c.name as company_name,
  c.primary_color,
  c.background_color,
  c.logo_url,
  
  -- Textos de UI
  ut.screen,
  ut.element,
  ut.language,
  ut.text_value,
  ut.is_enabled as text_enabled,
  
  -- Elementos de UI
  uec.element_key,
  uec.is_enabled as element_enabled,
  uec.display_order,
  uec.custom_properties,
  
  -- Caché de traducciones
  utc.language as cache_language,
  utc.last_updated as cache_last_updated
  
FROM companies c
LEFT JOIN ui_texts ut ON c.id = ut.company_id
LEFT JOIN ui_elements_config uec ON c.id = uec.company_id
LEFT JOIN ui_translations_cache utc ON c.id = utc.company_id;

-- ========================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ========================================

-- Índices para vistas de estadísticas
CREATE INDEX IF NOT EXISTS idx_active_sessions_start_time ON active_sessions(start_time);
CREATE INDEX IF NOT EXISTS idx_active_sessions_company_id ON active_sessions(company_id);
CREATE INDEX IF NOT EXISTS idx_active_sessions_zone_id ON active_sessions(zone_id);
CREATE INDEX IF NOT EXISTS idx_active_sessions_kiosk_id ON active_sessions(kiosk_id);

-- Índices para vistas de kioscos
CREATE INDEX IF NOT EXISTS idx_kiosks_last_connection ON kiosks(last_connection);
CREATE INDEX IF NOT EXISTS idx_kiosks_company_id ON kiosks(company_id);
CREATE INDEX IF NOT EXISTS idx_kiosks_status ON kiosks(status);

-- Índices para vistas de operadores
CREATE INDEX IF NOT EXISTS idx_operators_company_id ON operators(company_id);
CREATE INDEX IF NOT EXISTS idx_operators_role ON operators(role);

-- ========================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- ========================================

COMMENT ON VIEW v_company_complete IS 'Vista completa de empresa con toda su configuración y estadísticas';
COMMENT ON VIEW v_zones_with_company IS 'Zonas con información de empresa y estadísticas';
COMMENT ON VIEW v_active_sessions_details IS 'Sesiones activas con detalles completos y cálculos de tiempo';
COMMENT ON VIEW v_kiosks_status IS 'Estado completo de kioscos con estadísticas y estado de conexión';
COMMENT ON VIEW v_company_stats IS 'Estadísticas agregadas por empresa';
COMMENT ON VIEW v_daily_income_summary IS 'Resumen de ingresos por día y empresa';
COMMENT ON VIEW v_top_zones_by_income IS 'Top zonas ordenadas por ingresos';
COMMENT ON VIEW v_operators_with_stats IS 'Operadores con sus estadísticas y kiosco asignado';
COMMENT ON VIEW v_ui_config_by_company IS 'Configuración completa de UI por empresa';

-- ========================================
-- PERMISOS DE ACCESO A VISTAS
-- ========================================

-- Otorgar permisos de lectura a usuarios autenticados
GRANT SELECT ON v_company_complete TO authenticated;
GRANT SELECT ON v_zones_with_company TO authenticated;
GRANT SELECT ON v_active_sessions_details TO authenticated;
GRANT SELECT ON v_kiosks_status TO authenticated;
GRANT SELECT ON v_company_stats TO authenticated;
GRANT SELECT ON v_daily_income_summary TO authenticated;
GRANT SELECT ON v_top_zones_by_income TO authenticated;
GRANT SELECT ON v_operators_with_stats TO authenticated;
GRANT SELECT ON v_ui_config_by_company TO authenticated;
