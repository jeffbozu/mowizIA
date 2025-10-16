# Sistema de Permisos y Roles - MEYPARK

## 🎯 Objetivo

Este documento define el sistema de permisos y roles para el Centro de Control de MEYPARK, permitiendo gestión granular de accesos y funcionalidades.

## 👥 Roles del Sistema

### 1. **Superadmin** (Nivel 0)
- **Descripción**: Acceso completo a todo el sistema
- **Permisos**: 
  - ✅ Gestionar todas las empresas
  - ✅ Crear/eliminar empresas
  - ✅ Acceso a todos los datos
  - ✅ Configuración del sistema
  - ✅ Logs y auditoría

### 2. **Admin** (Nivel 1)
- **Descripción**: Administrador de empresa
- **Permisos**:
  - ✅ Gestionar su empresa
  - ✅ Crear/editar operadores
  - ✅ Configurar zonas y tarifas
  - ✅ Personalizar textos y UI
  - ✅ Ver estadísticas de su empresa
  - ❌ Acceso a otras empresas

### 3. **Operator** (Nivel 2)
- **Descripción**: Operador de kiosco
- **Permisos**:
  - ✅ Gestionar sesiones de estacionamiento
  - ✅ Ver estadísticas básicas
  - ✅ Configurar accesibilidad
  - ❌ Cambiar tarifas
  - ❌ Gestionar otros operadores

### 4. **Viewer** (Nivel 3)
- **Descripción**: Solo lectura
- **Permisos**:
  - ✅ Ver datos de su empresa
  - ✅ Ver estadísticas
  - ❌ Modificar cualquier dato

## 🔐 Estructura de Permisos

### Tabla: `user_roles`
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

### Tabla: `permission_templates`
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

## 📋 Permisos por Recurso

### 1. **Empresas (companies)**
```json
{
  "superadmin": {
    "create": true,
    "read": true,
    "update": true,
    "delete": true,
    "conditions": {}
  },
  "admin": {
    "create": false,
    "read": true,
    "update": true,
    "delete": false,
    "conditions": {
      "company_id": "user.company_id"
    }
  },
  "operator": {
    "create": false,
    "read": true,
    "update": false,
    "delete": false,
    "conditions": {
      "company_id": "user.company_id"
    }
  },
  "viewer": {
    "create": false,
    "read": true,
    "update": false,
    "delete": false,
    "conditions": {
      "company_id": "user.company_id"
    }
  }
}
```

### 2. **Zonas (zones)**
```json
{
  "superadmin": {
    "create": true,
    "read": true,
    "update": true,
    "delete": true,
    "conditions": {}
  },
  "admin": {
    "create": true,
    "read": true,
    "update": true,
    "delete": true,
    "conditions": {
      "company_id": "user.company_id"
    }
  },
  "operator": {
    "create": false,
    "read": true,
    "update": false,
    "delete": false,
    "conditions": {
      "company_id": "user.company_id"
    }
  },
  "viewer": {
    "create": false,
    "read": true,
    "update": false,
    "delete": false,
    "conditions": {
      "company_id": "user.company_id"
    }
  }
}
```

### 3. **Operadores (operators)**
```json
{
  "superadmin": {
    "create": true,
    "read": true,
    "update": true,
    "delete": true,
    "conditions": {}
  },
  "admin": {
    "create": true,
    "read": true,
    "update": true,
    "delete": true,
    "conditions": {
      "company_id": "user.company_id"
    }
  },
  "operator": {
    "create": false,
    "read": true,
    "update": false,
    "delete": false,
    "conditions": {
      "company_id": "user.company_id",
      "id": "user.id"
    }
  },
  "viewer": {
    "create": false,
    "read": true,
    "update": false,
    "delete": false,
    "conditions": {
      "company_id": "user.company_id"
    }
  }
}
```

### 4. **Sesiones (active_sessions)**
```json
{
  "superadmin": {
    "create": true,
    "read": true,
    "update": true,
    "delete": true,
    "conditions": {}
  },
  "admin": {
    "create": true,
    "read": true,
    "update": true,
    "delete": true,
    "conditions": {
      "company_id": "user.company_id"
    }
  },
  "operator": {
    "create": true,
    "read": true,
    "update": true,
    "delete": true,
    "conditions": {
      "company_id": "user.company_id"
    }
  },
  "viewer": {
    "create": false,
    "read": true,
    "update": false,
    "delete": false,
    "conditions": {
      "company_id": "user.company_id"
    }
  }
}
```

## 🛡️ Row Level Security (RLS)

### Políticas RLS por Tabla

#### 1. **companies**
```sql
-- Superadmin puede ver todo
CREATE POLICY "superadmin_all_access" ON companies
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = auth.uid()
      AND ur.role_name = 'superadmin'
      AND ur.is_active = true
    )
  );

-- Admin puede ver solo su empresa
CREATE POLICY "admin_company_access" ON companies
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = auth.uid()
      AND ur.role_name = 'admin'
      AND ur.company_id = companies.id
      AND ur.is_active = true
    )
  );

-- Operator y Viewer pueden leer solo su empresa
CREATE POLICY "operator_viewer_company_read" ON companies
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = auth.uid()
      AND ur.role_name IN ('operator', 'viewer')
      AND ur.company_id = companies.id
      AND ur.is_active = true
    )
  );
```

#### 2. **zones**
```sql
-- Superadmin puede ver todo
CREATE POLICY "superadmin_zones_all_access" ON zones
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = auth.uid()
      AND ur.role_name = 'superadmin'
      AND ur.is_active = true
    )
  );

-- Admin puede gestionar zonas de su empresa
CREATE POLICY "admin_zones_company_access" ON zones
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = auth.uid()
      AND ur.role_name = 'admin'
      AND ur.company_id = zones.company_id
      AND ur.is_active = true
    )
  );

-- Operator y Viewer pueden leer zonas de su empresa
CREATE POLICY "operator_viewer_zones_read" ON zones
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = auth.uid()
      AND ur.role_name IN ('operator', 'viewer')
      AND ur.company_id = zones.company_id
      AND ur.is_active = true
    )
  );
```

## 🔧 Funciones de Utilidad

### 1. **Verificar Permisos**
```sql
CREATE OR REPLACE FUNCTION check_permission(
  user_id UUID,
  resource_type TEXT,
  action TEXT,
  resource_company_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
  user_role TEXT;
  user_company_id UUID;
BEGIN
  -- Obtener rol y empresa del usuario
  SELECT ur.role_name, ur.company_id
  INTO user_role, user_company_id
  FROM user_roles ur
  WHERE ur.user_id = check_permission.user_id
  AND ur.is_active = true;
  
  -- Superadmin tiene acceso a todo
  IF user_role = 'superadmin' THEN
    RETURN TRUE;
  END IF;
  
  -- Verificar permisos específicos según el rol
  CASE user_role
    WHEN 'admin' THEN
      -- Admin puede gestionar su empresa
      RETURN resource_company_id IS NULL OR resource_company_id = user_company_id;
    WHEN 'operator' THEN
      -- Operator puede leer y gestionar sesiones de su empresa
      RETURN action IN ('read', 'create', 'update', 'delete') 
        AND (resource_company_id IS NULL OR resource_company_id = user_company_id);
    WHEN 'viewer' THEN
      -- Viewer solo puede leer datos de su empresa
      RETURN action = 'read' 
        AND (resource_company_id IS NULL OR resource_company_id = user_company_id);
    ELSE
      RETURN FALSE;
  END CASE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2. **Obtener Usuario Actual**
```sql
CREATE OR REPLACE FUNCTION get_current_user_info()
RETURNS TABLE(
  user_id UUID,
  role_name TEXT,
  company_id UUID,
  company_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ur.user_id,
    ur.role_name,
    ur.company_id,
    c.name as company_name
  FROM user_roles ur
  LEFT JOIN companies c ON ur.company_id = c.id
  WHERE ur.user_id = auth.uid()
  AND ur.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## 📊 Vistas de Seguridad

### 1. **Vista de Usuarios con Roles**
```sql
CREATE VIEW v_users_with_roles AS
SELECT 
  u.id as user_id,
  u.email,
  ur.role_name,
  ur.company_id,
  c.name as company_name,
  ur.is_active,
  ur.created_at
FROM auth.users u
JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN companies c ON ur.company_id = c.id
WHERE ur.is_active = true;
```

### 2. **Vista de Permisos por Usuario**
```sql
CREATE VIEW v_user_permissions AS
SELECT 
  ur.user_id,
  ur.role_name,
  ur.company_id,
  pt.resource_type,
  pt.actions,
  pt.conditions
FROM user_roles ur
JOIN permission_templates pt ON ur.role_name = pt.role_name
WHERE ur.is_active = true;
```

## 🚀 Implementación

### 1. **Crear Usuario Superadmin**
```sql
-- Insertar rol de superadmin
INSERT INTO user_roles (user_id, role_name, permissions)
VALUES (
  'user-uuid-here',
  'superadmin',
  '{"all": true}'
);
```

### 2. **Asignar Rol a Usuario**
```sql
-- Asignar rol de admin a usuario
INSERT INTO user_roles (user_id, company_id, role_name, permissions)
VALUES (
  'user-uuid-here',
  'company-uuid-here',
  'admin',
  '{"companies": true, "zones": true, "operators": true}'
);
```

### 3. **Verificar Permisos en Aplicación**
```dart
// En Flutter
Future<bool> checkPermission(String resource, String action) async {
  final response = await supabase.rpc('check_permission', params: {
    'user_id': supabase.auth.currentUser?.id,
    'resource_type': resource,
    'action': action,
  });
  return response as bool;
}
```

## 🔍 Auditoría y Logs

### Tabla de Auditoría
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

### Trigger de Auditoría
```sql
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_logs (
    user_id,
    action,
    resource_type,
    resource_id,
    old_values,
    new_values
  ) VALUES (
    auth.uid(),
    TG_OP,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

## 📋 Checklist de Implementación

- [ ] Crear tablas de roles y permisos
- [ ] Implementar políticas RLS
- [ ] Crear funciones de utilidad
- [ ] Configurar vistas de seguridad
- [ ] Implementar sistema de auditoría
- [ ] Crear usuario superadmin
- [ ] Probar permisos por rol
- [ ] Documentar procedimientos de seguridad

---

**¡El sistema de permisos está listo para el Centro de Control!** 🎯
