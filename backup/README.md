# Backup - Servidores Antiguos MEYPARK

## 📁 Contenido del Backup

Este directorio contiene todos los servidores y archivos de datos que fueron migrados a Supabase durante la migración completa del backend.

## 🗂️ Archivos Incluidos

### Servidores Node.js
- mock_backend.js - Servidor de sesiones y datos mock
- facturacion_server.js - Servidor de generación de facturas
- websocket_server.js - Servidor WebSocket para dashboard

### Datos JSON
- mock_data.json - Datos de empresas, operadores, zonas y configuración
- geographic_kiosks.json - Kioscos geográficos

### Archivos de Proceso
- *.pid - Archivos de proceso de los servidores

## 🔄 Migración Completada

Todos estos archivos han sido reemplazados por:

### Supabase Edge Functions
- supabase/functions/manage-sessions/ - Gestión de sesiones
- supabase/functions/generate-invoice/ - Generación de facturas
- supabase/functions/dashboard-api/ - API del dashboard

### Servicios Flutter
- lib/services/supabase_service.dart - Servicio principal de Supabase
- lib/services/supabase_realtime_service.dart - Sincronización en tiempo real
- lib/services/supabase_edge_functions_service.dart - Edge Functions
- lib/services/dynamic_translations_service.dart - Traducciones dinámicas

## ⚠️ Importante

- NO eliminar estos archivos hasta confirmar que todo funciona correctamente
- Estos archivos sirven como referencia y backup de seguridad
- Si hay problemas, se pueden restaurar temporalmente
- La migración está al 100% completada

## 📅 Fecha de Backup

16 de Octubre, 2024 - Migración completada exitosamente

## 🎯 Estado

✅ Migración 100% completada
✅ Todos los servidores migrados a Supabase
✅ Sistema funcionando sin dependencias locales
✅ Sincronización en tiempo real activa
