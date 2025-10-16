-- Crear vistas optimizadas para dashboard

-- Vista completa de empresa con configuraciones
CREATE OR REPLACE VIEW v_company_complete AS
SELECT 
    c.id,
    c.name,
    c.primary_color,
    c.background_color,
    c.logo_url,
    c.contact_email,
    c.contact_phone,
    c.address,
    c.is_active,
    c.created_at,
    c.updated_at,
    pc.accepted_coins,
    pc.min_payment,
    pc.max_payment,
    pc.payment_methods,
    ac.dark_mode,
    ac.high_contrast,
    ac.font_size,
    ac.voice_guide,
    ac.adaptive_ai,
    ac.simplified_mode,
    ac.reduce_animations,
    ic.business_name,
    ic.tax_id,
    ic.address as invoice_address,
    ic.phone as invoice_phone,
    ic.email as invoice_email,
    ic.logo_url as invoice_logo_url
FROM companies c
LEFT JOIN payment_config pc ON c.id = pc.company_id
LEFT JOIN accessibility_config ac ON c.id = ac.company_id
LEFT JOIN invoice_config ic ON c.id = ic.company_id
WHERE c.is_active = true;

-- Vista de zonas con información de empresa
CREATE OR REPLACE VIEW v_zones_with_company AS
SELECT 
    z.id,
    z.company_id,
    c.name as company_name,
    c.primary_color,
    z.name as zone_name,
    z.price_per_hour,
    z.max_hours,
    z.time_options,
    z.time_increment,
    z.min_time,
    z.is_active,
    z.created_at,
    z.updated_at
FROM zones z
JOIN companies c ON z.company_id = c.id
WHERE z.is_active = true AND c.is_active = true;

-- Vista de sesiones activas con detalles
CREATE OR REPLACE VIEW v_active_sessions_details AS
SELECT 
    s.id,
    s.company_id,
    c.name as company_name,
    s.zone_id,
    z.name as zone_name,
    z.price_per_hour,
    s.plate,
    s.start_time,
    s.end_time,
    s.total_price,
    s.payment_method,
    s.status,
    s.created_at,
    s.updated_at,
    EXTRACT(EPOCH FROM (COALESCE(s.end_time, NOW()) - s.start_time))/3600 as hours_elapsed
FROM active_sessions s
JOIN companies c ON s.company_id = c.id
JOIN zones z ON s.zone_id = z.id
WHERE s.status = 'active';

-- Vista de estado de kioscos
CREATE OR REPLACE VIEW v_kiosks_status AS
SELECT 
    k.id,
    k.company_id,
    c.name as company_name,
    k.name as kiosk_name,
    k.location,
    k.status,
    k.last_heartbeat,
    k.created_at,
    k.updated_at,
    CASE 
        WHEN k.last_heartbeat IS NULL THEN 'offline'
        WHEN k.last_heartbeat < NOW() - INTERVAL '5 minutes' THEN 'offline'
        ELSE 'online'
    END as connection_status
FROM kiosks k
JOIN companies c ON k.company_id = c.id
WHERE c.is_active = true;

-- Vista de estadísticas de empresa
CREATE OR REPLACE VIEW v_company_stats AS
SELECT 
    c.id as company_id,
    c.name as company_name,
    COUNT(DISTINCT z.id) as total_zones,
    COUNT(DISTINCT o.id) as total_operators,
    COUNT(DISTINCT k.id) as total_kiosks,
    COUNT(DISTINCT s.id) as active_sessions,
    COALESCE(SUM(s.total_price), 0) as total_revenue,
    COALESCE(AVG(s.total_price), 0) as avg_session_value
FROM companies c
LEFT JOIN zones z ON c.id = z.company_id AND z.is_active = true
LEFT JOIN operators o ON c.id = o.company_id AND o.is_active = true
LEFT JOIN kiosks k ON c.id = k.company_id
LEFT JOIN active_sessions s ON c.id = s.company_id AND s.status = 'active'
WHERE c.is_active = true
GROUP BY c.id, c.name;

-- Vista de resumen de ingresos diarios
CREATE OR REPLACE VIEW v_daily_income_summary AS
SELECT 
    DATE(s.created_at) as date,
    c.id as company_id,
    c.name as company_name,
    COUNT(s.id) as total_sessions,
    COALESCE(SUM(s.total_price), 0) as total_income,
    COALESCE(AVG(s.total_price), 0) as avg_session_value,
    COUNT(DISTINCT s.zone_id) as zones_used
FROM companies c
LEFT JOIN active_sessions s ON c.id = s.company_id
WHERE c.is_active = true
GROUP BY DATE(s.created_at), c.id, c.name
ORDER BY date DESC;

-- Vista de zonas más rentables
CREATE OR REPLACE VIEW v_top_zones_by_income AS
SELECT 
    z.id as zone_id,
    z.name as zone_name,
    c.id as company_id,
    c.name as company_name,
    z.price_per_hour,
    COUNT(s.id) as total_sessions,
    COALESCE(SUM(s.total_price), 0) as total_income,
    COALESCE(AVG(s.total_price), 0) as avg_session_value
FROM zones z
JOIN companies c ON z.company_id = c.id
LEFT JOIN active_sessions s ON z.id = s.zone_id
WHERE z.is_active = true AND c.is_active = true
GROUP BY z.id, z.name, c.id, c.name, z.price_per_hour
ORDER BY total_income DESC;

-- Vista de operadores con estadísticas
CREATE OR REPLACE VIEW v_operators_with_stats AS
SELECT 
    o.id as operator_id,
    o.username,
    o.role,
    o.is_active,
    c.id as company_id,
    c.name as company_name,
    o.created_at,
    o.updated_at,
    COUNT(s.id) as sessions_managed,
    COALESCE(SUM(s.total_price), 0) as revenue_generated
FROM operators o
JOIN companies c ON o.company_id = c.id
LEFT JOIN active_sessions s ON o.company_id = s.company_id
WHERE o.is_active = true AND c.is_active = true
GROUP BY o.id, o.username, o.role, o.is_active, c.id, c.name, o.created_at, o.updated_at;

-- Vista de configuración UI por empresa
CREATE OR REPLACE VIEW v_ui_config_by_company AS
SELECT 
    c.id as company_id,
    c.name as company_name,
    c.primary_color,
    c.background_color,
    c.logo_url,
    ut.screen,
    ut.element_key,
    ut.text_value,
    ut.language,
    uec.is_enabled,
    uec.is_visible
FROM companies c
LEFT JOIN ui_texts ut ON c.id = ut.company_id
LEFT JOIN ui_elements_config uec ON c.id = uec.company_id AND ut.screen = uec.screen AND ut.element_key = uec.element_key
WHERE c.is_active = true
ORDER BY c.name, ut.screen, ut.element_key;
