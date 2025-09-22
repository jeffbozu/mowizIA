#!/bin/bash

# Script para generar APK de MEYPARK Kiosco
# Uso: ./build_apk.sh [debug|release]

set -e

echo "🚀 MEYPARK Kiosco - Generador de APK"
echo "====================================="

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado o no está en el PATH"
    exit 1
fi

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ No se encontró pubspec.yaml. Ejecuta este script desde la raíz del proyecto Flutter"
    exit 1
fi

# Limpiar proyecto
echo "🧹 Limpiando proyecto..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Verificar configuración
echo "🔍 Verificando configuración..."
flutter doctor

# Determinar tipo de build
BUILD_TYPE=${1:-debug}

if [ "$BUILD_TYPE" = "release" ]; then
    echo "📱 Generando APK de RELEASE..."
    flutter build apk --release
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    echo "✅ APK de RELEASE generado: $APK_PATH"
else
    echo "📱 Generando APK de DEBUG..."
    flutter build apk --debug
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
    echo "✅ APK de DEBUG generado: $APK_PATH"
fi

# Mostrar información del APK
if [ -f "$APK_PATH" ]; then
    echo ""
    echo "📊 Información del APK:"
    echo "   Archivo: $APK_PATH"
    echo "   Tamaño: $(du -h "$APK_PATH" | cut -f1)"
    echo ""
    echo "📱 Para instalar en tu dispositivo:"
    echo "   adb install $APK_PATH"
    echo ""
    echo "🎉 ¡APK generado exitosamente!"
else
    echo "❌ Error: No se pudo generar el APK"
    exit 1
fi
