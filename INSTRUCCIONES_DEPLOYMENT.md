# Instrucciones de Deployment - MEYPARK Supabase

## 🎯 Estado Actual

✅ **Edge Functions desplegadas** - Las 4 Edge Functions están desplegadas en Supabase
- manage-sessions
- generate-invoice
- dashboard-api
- control-center

## 📋 Pasos Pendientes (Requieren Supabase Dashboard)

### 1. Crear Tablas en Supabase (CRÍTICO)

**Ir a**: https://supabase.com/dashboard/project/thfmuoqcrkhxduxuygro

1. Click en **SQL Editor** en el menú lateral
2. Click en **New Query**
3. Copiar y pegar el contenido completo de: `docs/supabase/setup_tables.sql`
4. Click en **Run** para ejecutar el script
5. Verificar que se crearon 11 tablas:
   - companies
   - operators
   - zones
   - payment_config
   - accessibility_config
   - kiosks
   - active_sessions
   - invoice_config
   - ui_texts
   - ui_translations_cache
   - ui_elements_config

### 2. Configurar Row Level Security (RLS)

Las políticas RLS están incluidas en el script `setup_tables.sql`, pero verifica que estén habilitadas:

1. Ir a **Table Editor**
2. Para cada tabla, verificar que RLS esté habilitado (icono de candado)
3. Click en cada tabla → **RLS Policies** → Verificar que hay políticas creadas

### 3. Crear Vistas Optimizadas

1. Ir a **SQL Editor** → **New Query**
2. Copiar y pegar el contenido de: `docs/supabase/VISTAS_OPTIMIZADAS.sql`
3. Click en **Run**
4. Verificar que se crearon 9 vistas:
   - v_company_complete
   - v_zones_with_company
   - v_active_sessions_details
   - v_kiosks_status
   - v_company_stats
   - v_daily_income_summary
   - v_top_zones_by_income
   - v_operators_with_stats
   - v_ui_config_by_company

### 4. Migrar Datos Iniciales

Una vez creadas las tablas, ejecutar desde terminal:

```bash
cd /home/i-d/flutter_projects/mi_nuevo_proyecto
dart run scripts/migrate_data.dart
```

Este script migrará:
- 2 empresas (MOWIZ, EYPSA)
- 4 operadores con passwords hasheados
- 5 zonas con configuraciones
- Configuraciones de pago y accesibilidad
- Textos UI en español

## 🧪 Testing (Después de Migrar Datos)

### Test 1: Sincronización en Tiempo Real
```bash
dart run scripts/test_realtime_sync.dart
```

### Test 2: Modo Offline
```bash
dart run scripts/test_offline_mode.dart
```

### Test 3: Edge Functions
```bash
dart run scripts/test_edge_functions.dart
```

### Test 4: Ejecutar App
```bash
flutter run
```

## ✅ Verificación Final

1. **Tablas creadas**: Ir a Table Editor y verificar 11 tablas
2. **Datos migrados**: Abrir tabla `companies` y verificar 2 empresas
3. **RLS configurado**: Verificar políticas en cada tabla
4. **Vistas creadas**: Ir a SQL Editor y verificar vistas
5. **Edge Functions**: Ir a Edge Functions y verificar 4 funciones desplegadas
6. **Tests pasando**: Ejecutar los 3 scripts de testing
7. **App funcionando**: Ejecutar app y verificar que carga datos desde Supabase

## 🚨 Notas Importantes

- **NO ejecutar** los scripts de testing hasta que las tablas estén creadas y los datos migrados
- El error 401 indica que las tablas no existen o RLS está bloqueando el acceso
- El error 404 indica que las tablas no existen
- Verificar siempre en Supabase Dashboard que los cambios se aplicaron correctamente

## 📊 Progreso Actual

- ✅ Edge Functions desplegadas (4/4)
- ⏳ Tablas creadas (0/11) - **PENDIENTE**
- ⏳ RLS configurado (0/11) - **PENDIENTE**
- ⏳ Datos migrados (0/1) - **PENDIENTE**
- ⏳ Vistas creadas (0/9) - **PENDIENTE**
- ⏳ Tests ejecutados (0/3) - **PENDIENTE**

## 🎯 Próximo Paso

**Crear las tablas en Supabase Dashboard** ejecutando el script `docs/supabase/setup_tables.sql` en SQL Editor.

