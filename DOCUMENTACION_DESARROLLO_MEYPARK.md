# DOCUMENTACIÓN TÉCNICA - SISTEMA MEYPARK
## Desarrollo de Aplicación de Gestión de Parquímetros

---

## ÍNDICE

1. [INTRODUCCIÓN](#introducción)
2. [TECNOLOGÍAS UTILIZADAS](#tecnologías-utilizadas)
3. [ARQUITECTURA DEL SISTEMA](#arquitectura-del-sistema)
4. [DESARROLLO DE LA APLICACIÓN](#desarrollo-de-la-aplicación)
5. [SISTEMA DE FACTURACIÓN](#sistema-de-facturación)
6. [PLATAFORMAS DE FACTURACIÓN ELECTRÓNICA](#plataformas-de-facturación-electrónica)
7. [PROCEDIMIENTO LEGAL PARA FACTURACIÓN](#procedimiento-legal-para-facturación)
8. [COSTOS Y PRESUPUESTOS](#costos-y-presupuestos)
9. [CONCLUSIONES](#conclusiones)

---

## 1. INTRODUCCIÓN

### 1.1 Descripción del Proyecto
MEYPARK es un sistema integral de gestión de parquímetros desarrollado para modernizar la administración de estacionamientos urbanos. El sistema incluye:

- Aplicación Flutter multiplataforma (Linux, Web, Android, iOS)
- Backend Node.js con WebSocket en tiempo real
- Sistema de facturación electrónica
- Dashboard administrativo web
- Integración con servicios de pago

### 1.2 Objetivos
- Digitalizar la gestión de parquímetros
- Implementar facturación electrónica legal
- Proporcionar datos en tiempo real
- Mejorar la experiencia del usuario
- Cumplir con normativas fiscales

---

## 2. TECNOLOGÍAS UTILIZADAS

### 2.1 Frontend - Flutter
**¿Qué es Flutter?**
Flutter es un framework de desarrollo de aplicaciones multiplataforma creado por Google que permite desarrollar aplicaciones nativas para iOS, Android, Web, Windows, macOS y Linux desde una sola base de código.

**Ventajas de Flutter:**
- Desarrollo multiplataforma con un solo código
- Alto rendimiento (compilación nativa)
- UI consistente en todas las plataformas
- Hot reload para desarrollo ágil
- Amplio ecosistema de paquetes

**Estructura del proyecto Flutter:**
```
lib/
├── main.dart                 # Punto de entrada
├── app_router.dart          # Navegación con GoRouter
├── data/
│   ├── models.dart          # Modelos de datos
│   └── mock_data.dart       # Datos de prueba
├── screens/                 # Pantallas de la aplicación
├── services/                # Servicios (WebSocket, almacenamiento)
├── widgets/                 # Componentes reutilizables
├── modals/                  # Modales y diálogos
└── theme/                   # Configuración de tema
```

### 2.2 Backend - Node.js
**Servicios implementados:**
- **mock_backend.js**: API REST para gestión de datos
- **websocket_server.js**: Comunicación en tiempo real
- **facturacion_server.js**: Servicio de facturación electrónica

### 2.3 Base de Datos
- **Almacenamiento local**: JSON files para desarrollo
- **Persistencia**: LocalStorageService para configuraciones
- **Sincronización**: WebSocket para datos en tiempo real

---

## 3. ARQUITECTURA DEL SISTEMA

### 3.1 Diagrama de Arquitectura
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Web Dashboard │    │   Web Kiosk     │
│   (Linux/Web)   │    │   (Admin Panel) │    │   (Public)      │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │      WebSocket Server     │
                    │      (Real-time)          │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │      Mock Backend         │
                    │      (REST API)          │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │   Facturación Server      │
                    │   (PDF Generation)       │
                    └───────────────────────────┘
```

### 3.2 Flujo de Datos
1. **Usuario inicia sesión** → Autenticación en backend
2. **Selección de zona** → Carga de tarifas desde backend
3. **Proceso de pago** → Validación y procesamiento
4. **Generación de factura** → PDF con datos fiscales
5. **Sincronización** → WebSocket actualiza dashboard

---

## 4. DESARROLLO DE LA APLICACIÓN

### 4.1 Cursor IDE
**¿Qué es Cursor?**
Cursor es un editor de código moderno basado en Visual Studio Code, potenciado con inteligencia artificial. Permite desarrollo ágil con asistencia de IA para:

- Generación de código automático
- Refactoring inteligente
- Debugging asistido
- Documentación automática
- Optimización de rendimiento

**Ventajas para el desarrollo:**
- Integración nativa con Flutter
- Hot reload automático
- Debugging avanzado
- Extensiones especializadas
- Colaboración en tiempo real

### 4.2 Metodología de Desarrollo
**Enfoque iterativo:**
1. **Fase 1**: Estructura básica y navegación
2. **Fase 2**: Integración con backend
3. **Fase 3**: Sistema de pagos
4. **Fase 4**: Facturación electrónica
5. **Fase 5**: Optimización y testing

### 4.3 Características Implementadas
**Pantallas principales:**
- Login con autenticación
- Selección de zona
- Configuración de tiempo
- Proceso de pago
- Generación de ticket
- Dashboard administrativo

**Funcionalidades avanzadas:**
- Acceso administrativo (5 toques en logo)
- Modo técnico (long press)
- Sugerencias inteligentes
- Guía por voz
- Modo simplificado
- Accesibilidad completa

---

## 5. SISTEMA DE FACTURACIÓN

### 5.1 Arquitectura de Facturación
El sistema de facturación está implementado en **facturacion_server.js** con las siguientes características:

**Funcionalidades:**
- Generación de PDFs con formato fiscal
- Numeración secuencial de facturas
- Datos fiscales completos
- Integración con base de datos
- API REST para consultas

**Estructura de factura:**
```javascript
{
  "numeroFactura": "TXN_1758263683563_76wy",
  "fecha": "2025-01-29T12:24:30.409093",
  "empresa": {
    "nombre": "MOWIZ Parking Solutions",
    "cif": "B12345678",
    "direccion": "Calle Principal 123, Madrid"
  },
  "cliente": {
    "matricula": "1234AAA",
    "zona": "Coche",
    "tiempo": "60 minutos",
    "precio": "1.20€"
  },
  "total": 1.20,
  "iva": 0.25,
  "totalConIva": 1.45
}
```

### 5.2 Generación de PDFs
**Tecnología utilizada:** PDFKit para Node.js
**Características del PDF:**
- Formato A4 estándar
- Logo y datos de empresa
- Numeración fiscal
- Desglose de IVA
- Código QR para verificación
- Firma digital (preparado)

---

## 6. PLATAFORMAS DE FACTURACIÓN ELECTRÓNICA

### 6.1 Odoo
**Descripción:** ERP completo con módulo de facturación electrónica
**Ventajas:**
- Integración completa con contabilidad
- Múltiples formatos fiscales
- Automatización de procesos
- Soporte técnico profesional

**Costos:**
- Community Edition: Gratuito (limitado)
- Enterprise Edition: Desde 25€/usuario/mes
- Implementación: 5,000€ - 15,000€
- Mantenimiento: 1,000€ - 3,000€/año

### 6.2 Otras Plataformas Disponibles

#### 6.2.1 Facturae (Gobierno Español)
**Descripción:** Sistema oficial del gobierno para facturación electrónica
**Ventajas:**
- Gratuito
- Cumplimiento legal garantizado
- Integración con AEAT
- Formato estándar

**Limitaciones:**
- Solo para administración pública
- No aplicable a empresas privadas

#### 6.2.2 A3Factura
**Descripción:** Software especializado en facturación electrónica
**Características:**
- Cumplimiento normativo completo
- Integración con contabilidad
- Soporte técnico especializado

**Costos:**
- Licencia: 300€ - 800€/año
- Implementación: 1,500€ - 3,000€
- Mantenimiento: 200€ - 500€/año

#### 6.2.3 ContaSOL
**Descripción:** Software de gestión empresarial
**Ventajas:**
- Facturación electrónica incluida
- Precio competitivo
- Fácil implementación

**Costos:**
- Licencia: 150€ - 400€/año
- Implementación: 800€ - 1,500€

#### 6.2.4 Sage
**Descripción:** ERP internacional con facturación electrónica
**Ventajas:**
- Solución empresarial completa
- Soporte internacional
- Escalabilidad

**Costos:**
- Licencia: 50€ - 200€/usuario/mes
- Implementación: 10,000€ - 50,000€

### 6.3 Comparativa de Costos

| Plataforma | Costo Inicial | Costo Anual | Implementación | Complejidad |
|------------|---------------|-------------|----------------|-------------|
| Odoo Community | 0€ | 0€ | 2,000€ | Media |
| Odoo Enterprise | 0€ | 3,000€ | 8,000€ | Alta |
| A3Factura | 0€ | 500€ | 2,000€ | Baja |
| ContaSOL | 0€ | 300€ | 1,000€ | Baja |
| Sage | 0€ | 6,000€ | 15,000€ | Alta |

---

## 7. PROCEDIMIENTO LEGAL PARA FACTURACIÓN

### 7.1 Requisitos Legales en España

#### 7.1.1 Normativa Aplicable
- **Ley 37/1992** del Impuesto sobre el Valor Añadido
- **Real Decreto 1619/2012** sobre facturación
- **Orden HAP/1005/2014** sobre facturación electrónica
- **Ley 25/2013** de impulso de la factura electrónica

#### 7.1.2 Requisitos Técnicos
**Formato de factura:**
- XML estructurado
- Firma electrónica válida
- Numeración secuencial
- Conservación 4 años
- Accesibilidad para AEAT

**Datos obligatorios:**
- Número y serie de factura
- Fecha de expedición
- Datos del emisor y receptor
- Descripción de servicios
- Base imponible e IVA
- Total de la factura

### 7.2 Procedimiento para Implementación Legal

#### 7.2.1 Fase 1: Preparación (1-2 semanas)
1. **Registro en AEAT**
   - Obtener certificado digital
   - Configurar firma electrónica
   - Registrar sistema de facturación

2. **Configuración técnica**
   - Instalar certificado digital
   - Configurar firma electrónica
   - Implementar numeración secuencial

#### 7.2.2 Fase 2: Desarrollo (2-4 semanas)
1. **Adaptación del sistema actual**
   - Modificar generación de PDFs
   - Implementar firma electrónica
   - Configurar envío automático

2. **Integración con AEAT**
   - Implementar envío SII
   - Configurar respaldo automático
   - Testing de integración

#### 7.2.3 Fase 3: Validación (1-2 semanas)
1. **Pruebas técnicas**
   - Validación de formatos
   - Verificación de firmas
   - Testing de envío

2. **Auditoría legal**
   - Revisión de cumplimiento
   - Validación de procesos
   - Documentación legal

### 7.3 Costos de Implementación Legal

#### 7.3.1 Costos Técnicos
- **Certificado digital**: 50€ - 150€/año
- **Firma electrónica**: 200€ - 500€/año
- **Servicios de envío**: 100€ - 300€/año
- **Almacenamiento seguro**: 200€ - 500€/año

#### 7.3.2 Costos de Desarrollo
- **Adaptación del sistema**: 3,000€ - 8,000€
- **Integración AEAT**: 2,000€ - 5,000€
- **Testing y validación**: 1,000€ - 2,000€
- **Documentación legal**: 500€ - 1,000€

#### 7.3.3 Costos Legales
- **Asesoría fiscal**: 1,000€ - 3,000€
- **Registro y trámites**: 300€ - 800€
- **Auditoría de cumplimiento**: 2,000€ - 5,000€

### 7.4 Presupuesto Total Estimado

| Concepto | Costo Mínimo | Costo Máximo | Costo Promedio |
|----------|--------------|--------------|----------------|
| Desarrollo técnico | 6,000€ | 15,000€ | 10,500€ |
| Servicios anuales | 550€ | 1,450€ | 1,000€ |
| Asesoría legal | 1,300€ | 3,800€ | 2,550€ |
| **TOTAL INICIAL** | **7,850€** | **20,250€** | **14,050€** |
| **TOTAL ANUAL** | **550€** | **1,450€** | **1,000€** |

---

## 8. COSTOS Y PRESUPUESTOS

### 8.1 Desarrollo del Sistema Actual

#### 8.1.1 Costos de Desarrollo
- **Desarrollo Flutter**: 15,000€ - 25,000€
- **Backend Node.js**: 8,000€ - 15,000€
- **Sistema de facturación**: 5,000€ - 10,000€
- **Dashboard web**: 3,000€ - 6,000€
- **Testing y optimización**: 2,000€ - 4,000€

#### 8.1.2 Costos de Infraestructura
- **Servidores**: 100€ - 300€/mes
- **Dominio y SSL**: 50€ - 100€/año
- **Backup y seguridad**: 200€ - 500€/año
- **Monitoreo**: 50€ - 150€/mes

### 8.2 Costos de Mantenimiento

#### 8.2.1 Mantenimiento Técnico
- **Desarrollador senior**: 3,000€ - 5,000€/mes
- **Soporte técnico**: 1,000€ - 2,000€/mes
- **Actualizaciones**: 500€ - 1,000€/mes
- **Backup y seguridad**: 200€ - 500€/mes

#### 8.2.2 Costos Legales
- **Asesoría fiscal**: 200€ - 500€/mes
- **Cumplimiento normativo**: 100€ - 300€/mes
- **Auditorías**: 1,000€ - 2,000€/año

### 8.3 ROI (Retorno de Inversión)

#### 8.3.1 Ahorros Generados
- **Reducción de personal**: 2,000€ - 4,000€/mes
- **Eliminación de papel**: 200€ - 500€/mes
- **Automatización de procesos**: 1,000€ - 2,000€/mes
- **Reducción de errores**: 500€ - 1,000€/mes

#### 8.3.2 Ingresos Adicionales
- **Nuevos servicios**: 1,000€ - 3,000€/mes
- **Mejora de eficiencia**: 500€ - 1,500€/mes
- **Datos analíticos**: 200€ - 800€/mes

---

## 9. CONCLUSIONES

### 9.1 Logros Técnicos
- Sistema multiplataforma funcional
- Integración en tiempo real
- Facturación electrónica implementada
- Dashboard administrativo completo
- Optimización de rendimiento

### 9.2 Próximos Pasos
1. **Implementación legal completa**
2. **Certificación de seguridad**
3. **Escalabilidad del sistema**
4. **Integración con más servicios**
5. **Optimización continua**

### 9.3 Recomendaciones
- Implementar facturación legal gradualmente
- Mantener backup de datos críticos
- Actualizar sistema regularmente
- Monitorear cumplimiento normativo
- Invertir en seguridad y privacidad

### 9.4 Ventajas Competitivas
- Tecnología moderna y escalable
- Costos de desarrollo optimizados
- Cumplimiento normativo preparado
- Flexibilidad de implementación
- Soporte técnico especializado

---

**Documento generado el:** 29 de Enero de 2025
**Versión:** 1.0
**Autor:** Sistema MEYPARK
**Estado:** Documentación técnica completa
