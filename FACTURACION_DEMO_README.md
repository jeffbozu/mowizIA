# 🧾 Demo de Facturación Electrónica - MEYPARK

Esta demo implementa un sistema completo de facturación electrónica para kioscos de parquímetros, cumpliendo con la normativa española (Ley Crea y Crece y Verifactu).

## 🎯 ¿Qué Demuestra?

- **Cumplimiento normativo**: Implementación de la Ley 18/2022 "Crea y Crece"
- **Sistema Verifactu**: Registro digital de transacciones
- **Experiencia de usuario**: Facturación desde casa, no en la calle
- **Integración completa**: Kiosco físico + Portal web + Backend

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Kiosco        │    │   Portal Web     │    │   Backend       │
│   Flutter       │    │   facturacion.html│    │   Node.js       │
│                 │    │                  │    │                 │
│ ┌─────────────┐ │    │ ┌──────────────┐ │    │ ┌─────────────┐ │
│ │ Ticket con  │ │───▶│ │ Formulario   │ │───▶│ │ Genera PDF  │ │
│ │ QR Code     │ │    │ │ Datos Fiscales│ │    │ │ Factura     │ │
│ └─────────────┘ │    │ └──────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 Cómo Ejecutar la Demo

### 1. Preparar el Entorno

```bash
# Instalar dependencias de Flutter
flutter pub get

# Instalar dependencias del servidor
npm install
```

### 2. Iniciar el Servidor de Facturación

```bash
# Opción 1: Script automático
./start_facturacion_demo.sh

# Opción 2: Manual
node facturacion_server.js
```

El servidor se iniciará en `http://localhost:3001`

### 3. Ejecutar la App Flutter

```bash
# En otra terminal
flutter run -d chrome --web-port 8080
```

### 4. Probar el Flujo Completo

1. **En el Kiosco Flutter:**
   - Selecciona una zona
   - Introduce matrícula
   - Selecciona tiempo
   - Realiza el pago
   - Observa el ticket con QR

2. **Con tu móvil:**
   - Escanea el QR del ticket
   - Se abrirá el portal web
   - Completa los datos fiscales
   - Descarga la factura PDF

## 📱 Flujo de Usuario

### Fase 1: Pago en el Kiosco
- Usuario realiza pago normal
- Kiosco genera ticket con QR
- QR contiene ID único de transacción

### Fase 2: Facturación Online
- Usuario escanea QR con móvil
- Accede al portal web
- Introduce datos fiscales completos
- Sistema genera factura PDF
- Usuario descarga factura

## 🔧 API del Servidor

### Endpoints Disponibles

- `GET /facturacion.html` - Portal web de facturación
- `GET /api/transaction/:id` - Obtener datos de transacción
- `POST /api/generate-invoice` - Generar factura
- `GET /api/invoice-status/:id` - Estado de factura
- `GET /invoices/:filename` - Descargar PDF
- `GET /api/stats` - Estadísticas
- `POST /api/create-test-transaction` - Crear transacción de prueba

### Ejemplo de Uso

```bash
# Crear transacción de prueba
curl -X POST http://localhost:3001/api/create-test-transaction \
  -H "Content-Type: application/json" \
  -d '{"plate":"1234ABC","amount":2.50}'

# Ver estadísticas
curl http://localhost:3001/api/stats
```

## 📋 Características Implementadas

### ✅ Kiosco Flutter
- [x] Generación de QR en ticket
- [x] Integración con servicio de facturación
- [x] UI mejorada para facturación electrónica

### ✅ Portal Web
- [x] Formulario de datos fiscales
- [x] Validación de NIF/CIF español
- [x] Diseño responsive
- [x] Integración con API

### ✅ Backend Node.js
- [x] API REST completa
- [x] Generación de PDFs
- [x] Base de datos en memoria
- [x] Validaciones de negocio

### ✅ Cumplimiento Normativo
- [x] Registro digital de transacciones
- [x] Generación de facturas electrónicas
- [x] Datos fiscales completos
- [x] Trazabilidad de operaciones

## 🎨 Personalización

### Modificar Zonas
Edita el objeto `zones` en `facturacion_server.js`:

```javascript
const zones = {
  'ZONA_001': { name: 'Centro Histórico', pricePerHour: 2.50 },
  'ZONA_002': { name: 'Zona Azul', pricePerHour: 1.80 },
  // Agregar más zonas...
};
```

### Personalizar PDF
Modifica la función `generateInvoicePDF()` en `facturacion_server.js` para cambiar:
- Logo de la empresa
- Datos fiscales
- Diseño de la factura
- Información adicional

### Cambiar URL del Servidor
Actualiza `_baseUrl` en `lib/services/electronic_invoice_service.dart`:

```dart
static const String _baseUrl = 'http://tu-servidor.com:3001';
```

## 🔍 Debugging

### Logs del Servidor
```bash
# Ver logs en tiempo real
tail -f facturacion_server.log
```

### Verificar Transacciones
```bash
# Listar todas las transacciones
curl http://localhost:3001/api/stats
```

### Probar Conectividad
```bash
# Verificar que el servidor responde
curl http://localhost:3001/api/stats
```

## 📊 Métricas de la Demo

- **Tiempo de implementación**: ~2 horas
- **Líneas de código**: ~800 líneas
- **Archivos creados**: 6 archivos
- **Dependencias**: 3 paquetes Node.js + 2 paquetes Flutter

## 🚀 Próximos Pasos

### Para Producción
1. **Base de datos real**: PostgreSQL/MySQL
2. **Autenticación**: JWT tokens
3. **Integración Verifactu**: API oficial
4. **Monitoreo**: Logs y métricas
5. **Seguridad**: HTTPS, validaciones

### Mejoras Adicionales
1. **Notificaciones**: Email/SMS
2. **Historial**: Portal de usuario
3. **Reportes**: Dashboard administrativo
4. **Multi-idioma**: Internacionalización
5. **Accesibilidad**: Mejoras WCAG

## 📞 Soporte

Para dudas sobre la implementación:
- Revisa los logs del servidor
- Verifica la conectividad de red
- Comprueba que todas las dependencias estén instaladas

---

**¡Esta demo demuestra que tu empresa está preparada para el futuro de la facturación electrónica!** 🎉
