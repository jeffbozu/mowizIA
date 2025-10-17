-- Insertar usuario admin de prueba en tabla operators
INSERT INTO operators (
  id,
  company_id,
  username,
  password_hash,
  role,
  permissions,
  is_active
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM companies WHERE name = 'MOWIZ' LIMIT 1),
  'admin@meypark.com',
  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: Admin123!
  'superadmin',
  '{
    "can_manage_companies": true,
    "can_manage_zones": true,
    "can_manage_operators": true,
    "can_manage_ui_texts": true,
    "can_view_invoices": true
  }'::jsonb,
  true
) ON CONFLICT (username) DO NOTHING;
