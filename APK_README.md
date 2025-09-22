# MEYPARK Kiosco - APK Android

## 📱 Información del APK

- **Nombre de la App**: MEYPARK
- **Package ID**: com.meypark.kiosco
- **Versión**: 1.0.0+2
- **Tipo**: Kiosco de parquímetro físico

### ✅ APKs Generados Exitosamente:

- **Debug APK**: `app-debug.apk` (92.6 MB)
  - Incluye símbolos de debug
  - Configuración de desarrollo
  - Sufijo `.debug` en package ID

- **Release APK**: `app-release.apk` (26.4 MB)
  - Optimizado para producción
  - Tamaño reducido
  - Listo para distribución

## 🚀 Cómo generar el APK

### Opción 1: Script automático (Recomendado)
```bash
# APK de debug (para testing)
./build_apk.sh debug

# APK de release (para producción)
./build_apk.sh release
```

### Opción 2: Comandos manuales
```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Generar APK de debug
flutter build apk --debug

# Generar APK de release
flutter build apk --release
```

## 📦 Ubicación de los APKs

- **Debug**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release**: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Instalación en dispositivo

### Método 1: ADB (Recomendado)
```bash
# Conectar dispositivo via USB y habilitar depuración USB
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Método 2: Transferencia manual
1. Copiar el archivo APK al dispositivo
2. Habilitar "Fuentes desconocidas" en configuración
3. Abrir el archivo APK desde el explorador de archivos

## 🔧 Configuraciones aplicadas

### Permisos incluidos:
- `INTERNET` - Para conexión con backend
- `ACCESS_NETWORK_STATE` - Verificar estado de red
- `WAKE_LOCK` - Mantener pantalla activa
- `VIBRATE` - Feedback háptico
- `WRITE_EXTERNAL_STORAGE` - Guardar archivos
- `READ_EXTERNAL_STORAGE` - Leer archivos

### Optimizaciones:
- Minificación habilitada en release
- Shrinking de recursos habilitado
- ProGuard configurado para Flutter
- Configuración de firma para testing

## 🧪 Testing recomendado

1. **Instalación**: Verificar que se instala sin errores
2. **Inicio**: Comprobar que la app inicia correctamente
3. **Navegación**: Probar todas las pantallas
4. **Funcionalidades**: Verificar facturación, QR, etc.
5. **Accesibilidad**: Probar modo simplificado y TTS
6. **Rendimiento**: Verificar fluidez en dispositivo real

## 🐛 Solución de problemas

### Error de instalación:
- Verificar que el dispositivo tiene espacio suficiente
- Desinstalar versión anterior si existe
- Verificar que "Fuentes desconocidas" está habilitado

### Error de compilación:
- Ejecutar `flutter clean` y `flutter pub get`
- Verificar que Flutter está actualizado
- Comprobar que Android SDK está configurado

### App no inicia:
- Verificar logs con `adb logcat`
- Comprobar permisos en configuración del dispositivo
- Verificar que el dispositivo es compatible (Android 5.0+)

## 📋 Requisitos del dispositivo

- **Android**: 5.0 (API 21) o superior
- **RAM**: Mínimo 2GB recomendado
- **Almacenamiento**: 100MB libres
- **Pantalla**: Mínimo 7" recomendado para kiosco
- **Conexión**: WiFi o datos móviles para backend

## 🔄 Actualizaciones

Para actualizar el APK:
1. Incrementar versión en `pubspec.yaml`
2. Ejecutar `./build_apk.sh release`
3. Instalar nueva versión en dispositivos
