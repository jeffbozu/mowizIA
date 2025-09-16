#!/bin/bash

echo "🚀 Iniciando MEYPARK Dashboard..."
echo "=================================="

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor instala Node.js primero."
    echo "   Visita: https://nodejs.org/"
    exit 1
fi

# Verificar si npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ npm no está instalado. Por favor instala npm primero."
    exit 1
fi

# Instalar dependencias si no existen
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Error instalando dependencias"
        exit 1
    fi
fi

# Verificar que los archivos del dashboard existen
if [ ! -f "web/dashboard.html" ]; then
    echo "❌ Archivo dashboard.html no encontrado en web/"
    exit 1
fi

if [ ! -f "web/dashboard.css" ]; then
    echo "❌ Archivo dashboard.css no encontrado en web/"
    exit 1
fi

if [ ! -f "web/dashboard.js" ]; then
    echo "❌ Archivo dashboard.js no encontrado en web/"
    exit 1
fi

echo "✅ Archivos del dashboard verificados"
echo "✅ Dependencias instaladas"
echo ""
echo "🌐 Iniciando servidor WebSocket..."
echo "📊 Dashboard estará disponible en: http://localhost:8080"
echo "🔌 WebSocket disponible en: ws://localhost:8080"
echo ""
echo "💡 Para detener el servidor, presiona Ctrl+C"
echo ""

# Iniciar el servidor
npm start
