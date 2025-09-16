# 🚀 MEYPARK Dashboard

Dashboard web completo para la gestión remota del sistema MEYPARK de parquímetros.

## 📋 Características

### 🏢 **Gestión de Empresas**
- ✅ Crear nuevas empresas con colores personalizados
- ✅ Editar empresas existentes
- ✅ Eliminar empresas
- ✅ Gestión de operadores por empresa

### 🗺️ **Gestión de Zonas**
- ✅ Crear zonas de estacionamiento
- ✅ Configurar precios por hora
- ✅ Establecer máximo de horas
- ✅ Asignar colores a zonas
- ✅ Vincular zonas a empresas

### 🖥️ **Monitoreo de Kioscos**
- ✅ Estado en tiempo real del kiosco
- ✅ Pantalla remota del kiosco
- ✅ Diagnósticos técnicos (red, impresora, pantalla, táctil, monedas, tarjetas)
- ✅ Control remoto de la aplicación

### 🚗 **Sesiones Activas**
- ✅ Ver sesiones de estacionamiento en tiempo real
- ✅ Extender sesiones existentes
- ✅ Finalizar sesiones manualmente
- ✅ Exportar datos a Excel

### 💳 **Gestión de Pagos**
- ✅ Monitoreo de ingresos en tiempo real
- ✅ Estadísticas por método de pago
- ✅ Historial de transacciones
- ✅ Reportes de ingresos

### 📊 **Reportes y Estadísticas**
- ✅ Gráficos de ingresos diarios
- ✅ Uso de zonas por empresa
- ✅ Estadísticas de uso del kiosco
- ✅ Exportación de datos

### ⚙️ **Configuración**
- ✅ Configuración de WebSocket
- ✅ Opciones de accesibilidad (modo oscuro, alto contraste, tamaño de fuente)
- ✅ Intervalos de actualización
- ✅ Configuración de servidor

## 🚀 Instalación y Uso

### **1. Instalar dependencias del servidor:**
```bash
npm install
```

### **2. Iniciar el servidor WebSocket:**
```bash
npm start
# o para desarrollo:
npm run dev
```

### **3. Acceder al dashboard:**
- Abrir navegador en: `http://localhost:8080`
- El dashboard se cargará automáticamente

### **4. Conectar el kiosco Flutter:**
- El kiosco se conecta automáticamente al WebSocket
- Los datos se sincronizan en tiempo real

## 🔧 Configuración

### **WebSocket Server:**
- **Puerto:** 8080 (configurable)
- **URL:** `ws://localhost:8080`
- **Protocolo:** WebSocket estándar

### **Dashboard:**
- **URL:** `http://localhost:8080`
- **Archivos:** `web/dashboard.html`, `web/dashboard.css`, `web/dashboard.js`

## 📱 Funcionalidades del Dashboard

### **Resumen General:**
- Estadísticas en tiempo real
- Empresas activas
- Zonas disponibles
- Sesiones activas
- Ingresos del día

### **Gestión de Empresas:**
- Crear empresa con nombre y colores
- Asignar operadores
- Configurar zonas
- Fecha de creación

### **Gestión de Zonas:**
- ID único de zona
- Nombre descriptivo
- Empresa asociada
- Precio por hora
- Máximo de horas
- Color de identificación

### **Monitoreo de Kioscos:**
- Estado de conexión
- Pantalla actual del kiosco
- Diagnósticos técnicos
- Control remoto

### **Sesiones Activas:**
- Matrícula del vehículo
- Zona asignada
- Hora de inicio y fin
- Precio total
- Estado de la sesión

### **Gestión de Pagos:**
- Método de pago utilizado
- Monto pagado
- Fecha y hora
- Estado de la transacción

## 🔌 Integración con Flutter

El dashboard se comunica con la app Flutter mediante WebSocket:

### **Mensajes del Kiosco al Dashboard:**
- `kiosk_status`: Estado del kiosco
- `screen_update`: Cambio de pantalla
- `session_update`: Actualización de sesión
- `payment_update`: Nuevo pago
- `diagnostics_update`: Diagnósticos técnicos

### **Mensajes del Dashboard al Kiosco:**
- `update_company`: Actualizar empresa
- `update_zones`: Actualizar zonas
- `update_ui`: Cambios de accesibilidad
- `restart_app`: Reiniciar aplicación

## 🎨 Accesibilidad

El dashboard incluye opciones de accesibilidad:

- **Modo Oscuro:** Interfaz con colores oscuros
- **Alto Contraste:** Mayor contraste para mejor legibilidad
- **Tamaño de Fuente:** Pequeño, Normal, Grande
- **Reducir Animaciones:** Menos efectos visuales

## 📊 Datos Simulados

El dashboard incluye datos de ejemplo para demostración:

- **2 Empresas:** MOWIZ Parking, EYPSA Estacionamientos
- **4 Zonas:** MZ-A, MZ-V, EY-V, EY-R
- **Sesiones Activas:** Ejemplos de estacionamientos
- **Pagos:** Historial de transacciones

## 🚀 Despliegue

### **Desarrollo Local:**
```bash
npm start
```

### **Producción:**
```bash
# Instalar dependencias
npm install --production

# Iniciar servidor
npm start
```

### **GitHub Pages:**
Los archivos del dashboard están en la carpeta `web/` y pueden desplegarse en GitHub Pages.

## 🔧 Solución de Problemas

### **WebSocket no conecta:**
1. Verificar que el servidor esté ejecutándose
2. Comprobar el puerto 8080
3. Revisar la configuración de red

### **Dashboard no carga:**
1. Verificar que los archivos estén en `web/`
2. Comprobar la consola del navegador
3. Verificar permisos de archivos

### **Datos no se sincronizan:**
1. Verificar conexión WebSocket
2. Comprobar logs del servidor
3. Revisar configuración del kiosco

## 📝 Notas Técnicas

- **Backend:** Node.js con WebSocket
- **Frontend:** HTML5, CSS3, JavaScript vanilla
- **Comunicación:** WebSocket bidireccional
- **Almacenamiento:** LocalStorage para configuración
- **Responsive:** Diseño adaptable a móviles

## 🎯 Próximas Funcionalidades

- [ ] Gráficos interactivos con Chart.js
- [ ] Exportación de reportes en PDF
- [ ] Notificaciones push
- [ ] Múltiples kioscos simultáneos
- [ ] Base de datos persistente
- [ ] Autenticación de usuarios
- [ ] Roles y permisos

---

**¡El dashboard está listo para usar! 🎉**

Para más información, consulta la documentación de la app Flutter o contacta al equipo de desarrollo.
