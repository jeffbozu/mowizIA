# 🚀 PARQUÍMETRO FLUTTER - RAMA FINAL1

## 📋 DESCRIPCIÓN COMPLETA

Esta es la **rama FINAL1** que contiene el proyecto completo del parquímetro Flutter con todas las funcionalidades implementadas:

- ✅ **Flutter App** con sistema de diseño unificado
- ✅ **Backend Node.js** con WebSocket
- ✅ **Sistema de Facturación** electrónica
- ✅ **Dashboard Web** en tiempo real
- ✅ **Sistema de Accesibilidad** avanzado
- ✅ **Multiidioma** (ES, EN, CA, GL, EU, FR, DE, IT, PT)

## 🏗️ ARQUITECTURA COMPLETA

### **Frontend Flutter**
- **Pantallas:** Home, Zona, Matrícula, Tiempo, Pago, Ticket, Extensión
- **Diseño:** Sistema unificado con glassmorphism
- **Accesibilidad:** Modo simplificado, guía por voz, IA adaptativa
- **Idiomas:** 9 idiomas soportados

### **Backend Node.js**
- **API REST:** `/api/data`, `/api/sessions`, `/api/payments`
- **WebSocket:** Comunicación en tiempo real
- **Base de datos:** JSON con persistencia
- **Facturación:** Generación de PDFs electrónicos

### **Dashboard Web**
- **Monitoreo:** Kioscos en tiempo real
- **Estadísticas:** Ingresos, sesiones activas
- **Gestión:** Operadores, empresas, zonas

## 🚀 INSTRUCCIONES DE INSTALACIÓN

### **1. Requisitos Previos**
```bash
# Flutter SDK
flutter --version

# Node.js
node --version
npm --version

# Git
git --version
```

### **2. Clonar el Repositorio**
```bash
git clone https://github.com/jeffbozu/mowizIA.git
cd mowizIA
git checkout FINAL1
```

### **3. Instalar Dependencias Flutter**
```bash
flutter pub get
```

### **4. Instalar Dependencias Node.js**
```bash
npm install
```

### **5. Ejecutar el Sistema Completo**
```bash
# Opción 1: Ejecutar todo automáticamente
./start_all.sh

# Opción 2: Ejecutar por separado
# Terminal 1: Backend
node mock_backend.js

# Terminal 2: WebSocket
node websocket_server.js

# Terminal 3: Servidor de Facturación
node facturacion_server.js

# Terminal 4: Flutter App
flutter run -d linux
```

## 📱 FUNCIONALIDADES IMPLEMENTADAS

### **🎨 Sistema de Diseño Unificado**
- **Glassmorphism:** Efectos de vidrio esmerilado
- **Colores corporativos:** #E62144 (rojo), gradientes
- **Iconos modernos:** Material Design 3
- **Animaciones suaves:** Transiciones fluidas

### **🌍 Sistema Multiidioma**
- **Español (ES):** Idioma principal
- **Inglés (EN):** Traducción completa
- **Catalán (CA):** Soporte regional
- **Gallego (GL):** Soporte regional
- **Euskera (EU):** Soporte regional
- **Francés (FR):** Soporte internacional
- **Alemán (DE):** Soporte internacional
- **Italiano (IT):** Soporte internacional
- **Portugués (PT):** Soporte internacional

### **♿ Accesibilidad Avanzada**
- **Modo simplificado:** UI simplificada
- **Guía por voz:** TTS con configuración
- **IA adaptativa:** Aprendizaje automático
- **Alto contraste:** Modo accesible
- **Tamaños de fuente:** Pequeño, normal, grande

### **💳 Sistema de Pagos**
- **Monedas:** 0.05€, 0.10€, 0.20€, 0.50€, 1€, 2€
- **Tarjetas:** Visa, Mastercard, American Express
- **Validación:** Formato de matrícula español
- **Cálculos:** Precios automáticos por zona

### **📊 Dashboard en Tiempo Real**
- **Monitoreo:** Estado de kioscos
- **Estadísticas:** Ingresos diarios
- **Sesiones:** Activas y finalizadas
- **WebSocket:** Actualizaciones en vivo

## 🔧 CONFIGURACIÓN

### **Variables de Entorno**
```bash
# Puerto del backend
BACKEND_PORT=8082

# Puerto del WebSocket
WEBSOCKET_PORT=8083

# Puerto del servidor de facturación
FACTURACION_PORT=8084

# Puerto del dashboard web
DASHBOARD_PORT=8085
```

### **Configuración de Empresas**
```json
{
  "companies": {
    "mowiz-company": {
      "name": "MOWIZ",
      "primaryColor": "#E62144"
    },
    "eysa-company": {
      "name": "EYSA", 
      "primaryColor": "#2196F3"
    }
  }
}
```

## 📁 ESTRUCTURA DE ARCHIVOS

```
mi_nuevo_proyecto/
├── lib/                          # Código Flutter
│   ├── screens/                  # Pantallas principales
│   ├── services/                  # Servicios (WebSocket, TTS, etc.)
│   ├── widgets/                   # Componentes reutilizables
│   ├── data/                     # Modelos y datos
│   └── i18n/                     # Traducciones
├── web/                          # Dashboard web
├── mock_backend.js               # Backend Node.js
├── websocket_server.js           # Servidor WebSocket
├── facturacion_server.js         # Servidor de facturación
├── start_all.sh                  # Script de inicio completo
└── README_FINAL1.md             # Este archivo
```

## 🚀 COMANDOS ÚTILES

### **Desarrollo**
```bash
# Hot reload Flutter
flutter run -d linux

# Reiniciar backend
pkill -f mock_backend.js && node mock_backend.js

# Ver logs
tail -f flutter.log
tail -f mock_backend.log
```

### **Producción**
```bash
# Compilar APK
flutter build apk --release

# Compilar para Linux
flutter build linux --release
```

## 🔍 TROUBLESHOOTING

### **Problemas Comunes**

1. **Puerto ocupado:**
```bash
# Encontrar proceso
lsof -i :8082
# Matar proceso
kill -9 <PID>
```

2. **WebSocket no conecta:**
```bash
# Verificar servidor
curl http://localhost:8082/api/data
```

3. **Flutter no compila:**
```bash
# Limpiar cache
flutter clean
flutter pub get
```

## 📞 SOPORTE

- **Documentación:** Ver archivos README específicos
- **Issues:** Crear issue en GitHub
- **Contacto:** jeffbozu@github.com

## 🎯 PRÓXIMOS PASOS

1. **Testing:** Implementar tests automatizados
2. **CI/CD:** Pipeline de despliegue automático
3. **Monitoreo:** Sistema de alertas
4. **Escalabilidad:** Base de datos real (PostgreSQL)

---

## ✅ ESTADO ACTUAL

- **Rama:** FINAL1
- **Versión:** 1.0.0
- **Estado:** ✅ COMPLETO Y FUNCIONAL
- **Última actualización:** $(date)

**¡El proyecto está listo para usar en cualquier PC del mundo!** 🌍🚀
