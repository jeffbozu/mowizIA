# 🚀 MOWIZIA - MEYPARK Sistema de Parquímetro

![MEYPARK Logo](https://img.shields.io/badge/MEYPARK-Parquímetro%20Inteligente-E62144?style=for-the-badge&logo=flutter)

## 📋 Descripción

**MOWIZIA** es un sistema completo de parquímetro inteligente desarrollado en Flutter con dashboard web de gestión remota. Simula un kiosco físico de parquímetro con capacidades de gestión en tiempo real.

## ✨ Características Principales

### 🎯 **App Flutter (Kiosco)**
- **Pantallas completas**: Login, Selección de Zona, Matrícula, Tiempo, Pago, Ticket
- **Gestos ocultos**: Modo Admin (5 taps), Modo Técnico (3s long-press)
- **Accesibilidad completa**: Modo oscuro, alto contraste, tamaños de fuente
- **Multiidioma**: Español e Inglés con traducción instantánea
- **WebSocket**: Comunicación en tiempo real con dashboard

### 🌐 **Dashboard Web**
- **Gestión de empresas**: Crear, editar, eliminar empresas
- **Gestión de zonas**: Configurar zonas de estacionamiento y tarifas
- **Monitoreo en vivo**: Visualización en tiempo real de la pantalla del kiosco
- **Gestión de operadores**: Cambiar credenciales de acceso
- **Sincronización**: Actualización automática de precios y configuraciones
- **Accesibilidad**: Modo oscuro, alto contraste, tamaños de fuente

### 🔄 **Sincronización en Tiempo Real**
- **WebSocket bidireccional**: Comunicación instantánea
- **Actualización de credenciales**: Cambios en tiempo real
- **Sincronización de precios**: Tarifas actualizables desde dashboard
- **Monitoreo de pantalla**: Visualización en vivo del kiosco

## 🛠️ Tecnologías Utilizadas

- **Flutter 3.x** - Framework principal
- **Material 3** - Sistema de diseño
- **WebSocket** - Comunicación en tiempo real
- **Node.js** - Servidor WebSocket
- **HTML/CSS/JavaScript** - Dashboard web
- **GitHub Pages** - Despliegue del dashboard

## 🚀 Instalación y Uso

### **Prerrequisitos**
- Flutter 3.x instalado
- Node.js instalado
- Navegador web moderno

### **1. Clonar el repositorio**
```bash
git clone https://github.com/jeffbozu/mowizIA.git
cd mowizIA
```

### **2. Instalar dependencias Flutter**
```bash
flutter pub get
```

### **3. Instalar dependencias Node.js**
```bash
npm install
```

### **4. Iniciar el sistema completo**
```bash
./start_dashboard.sh
```

### **5. Acceder al dashboard**
Abrir `web/dashboard.html` en el navegador

## 📱 Funcionalidades del Kiosco

### **Pantallas Principales**
1. **Login**: Autenticación de operadores
2. **Selección de Zona**: Elegir zona de estacionamiento
3. **Matrícula**: Introducir matrícula del vehículo
4. **Tiempo**: Seleccionar duración del estacionamiento
5. **Pago**: Procesar pago (monedas, tarjeta)
6. **Ticket**: Generar y mostrar ticket

### **Gestos Ocultos**
- **Modo Admin**: 5 taps en el logo MEYPARK
- **Modo Técnico**: 3 segundos de presión larga en el logo

### **Accesibilidad**
- Modo oscuro/claro
- Alto contraste
- Tamaños de fuente (Pequeño, Normal, Grande)
- Reducir animaciones

## 🌐 Funcionalidades del Dashboard

### **Gestión de Empresas**
- Crear nuevas empresas
- Editar información existente
- Cambiar credenciales de acceso
- Configurar colores y branding

### **Gestión de Zonas**
- Crear zonas de estacionamiento
- Configurar tarifas por hora
- Establecer tiempo máximo
- Ajustar precios en tiempo real

### **Monitoreo en Vivo**
- Visualización de la pantalla del kiosco
- Estado de conexión
- Diagnósticos del sistema
- Estadísticas en tiempo real

## 🔧 Configuración

### **Empresas por Defecto**
- **MOWIZ**: `mowiz_admin` / `Mo2025!`
- **EYPSA**: `eypsa_admin` / `Ey2025!`

### **Zonas de Estacionamiento**
- **MOWIZ MZ-V**: 2.10€/h, máximo 24h
- **EYPSA EY-V**: 2.40€/h, máximo 24h
- **EYPSA EY-R**: 0.50€/h, máximo 24h

## 📊 Estructura del Proyecto

```
mowizIA/
├── lib/                    # Código Flutter
│   ├── main.dart          # Punto de entrada
│   ├── screens/           # Pantallas de la app
│   ├── services/          # Servicios WebSocket
│   ├── data/              # Datos mock
│   ├── i18n/              # Internacionalización
│   └── theme/             # Temas y estilos
├── web/                   # Dashboard web
│   ├── dashboard.html     # Interfaz principal
│   ├── dashboard.js       # Lógica JavaScript
│   └── dashboard.css      # Estilos
├── websocket_server.js    # Servidor WebSocket
├── start_dashboard.sh     # Script de inicio
└── package.json           # Dependencias Node.js
```

## 🎯 Casos de Uso

### **Para Operadores**
1. Iniciar sesión en el kiosco
2. Seleccionar zona de estacionamiento
3. Introducir matrícula del vehículo
4. Seleccionar tiempo de estacionamiento
5. Procesar pago
6. Generar ticket

### **Para Administradores**
1. Acceder al dashboard web
2. Gestionar empresas y zonas
3. Monitorear kioscos en tiempo real
4. Actualizar precios y configuraciones
5. Ver estadísticas y reportes

## 🔒 Seguridad

- **Autenticación**: Sistema de login seguro
- **WebSocket**: Comunicación encriptada
- **Validación**: Verificación de datos de entrada
- **Acceso**: Gestión de permisos por roles

## 📈 Roadmap

- [ ] Integración con sistemas de pago reales
- [ ] Aplicación móvil para usuarios
- [ ] Sistema de notificaciones
- [ ] Reportes avanzados
- [ ] Integración con sensores IoT

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 👥 Autores

- **Desarrollado por**: Equipo MOWIZIA
- **Contacto**: [GitHub](https://github.com/jeffbozu)

## 🙏 Agradecimientos

- Flutter Team por el framework
- Material Design por el sistema de diseño
- Comunidad open source por las librerías utilizadas

---

**¡Gracias por usar MOWIZIA! 🚀**

*Sistema de parquímetro inteligente con gestión remota en tiempo real*