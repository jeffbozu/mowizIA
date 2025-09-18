#!/bin/bash

echo "🚀 Iniciando Demo de Facturación Electrónica MEYPARK"
echo "=================================================="

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor, instálalo primero."
    echo "   Visita: https://nodejs.org/"
    exit 1
fi

# Verificar si npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ npm no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Crear package.json si no existe
if [ ! -f "package.json" ]; then
    echo "📦 Creando package.json para el servidor de facturación..."
    cp package_facturacion.json package.json
fi

# Instalar dependencias si no existen
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias del servidor..."
    npm install
fi

# Crear directorio de facturas si no existe
mkdir -p invoices

echo ""
echo "🎯 Instrucciones para la Demo:"
echo "=============================="
echo ""
echo "1. El servidor de facturación se iniciará en: http://localhost:3001"
echo "2. El portal web estará disponible en: http://localhost:3001/facturacion.html"
echo "3. Ejecuta la app Flutter en otra terminal:"
echo "   flutter run -d chrome --web-port 8080"
echo ""
echo "4. Para probar el flujo completo:"
echo "   - Realiza un pago en el kiosco Flutter"
echo "   - Escanea el QR del ticket con tu móvil"
echo "   - Completa el formulario de facturación"
echo "   - Descarga la factura PDF"
echo ""
echo "5. Para crear una transacción de prueba:"
echo "   curl -X POST http://localhost:3001/api/create-test-transaction"
echo ""

# Iniciar servidor
echo "🚀 Iniciando servidor de facturación..."
node facturacion_server.js
