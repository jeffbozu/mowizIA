#!/bin/bash

# 🚀 SCRIPT DE INSTALACIÓN AUTOMÁTICA - RAMA FINAL1
# Parquímetro Flutter Completo con Backend + WebSocket + Facturación

echo "🚀 INSTALANDO PARQUÍMETRO FLUTTER - RAMA FINAL1"
echo "================================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si estamos en la rama correcta
print_status "Verificando rama actual..."
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "FINAL1" ]; then
    print_warning "No estás en la rama FINAL1. Cambiando a FINAL1..."
    git checkout FINAL1
    if [ $? -ne 0 ]; then
        print_error "No se pudo cambiar a la rama FINAL1"
        exit 1
    fi
fi
print_success "Rama FINAL1 activa"

# Verificar requisitos previos
print_status "Verificando requisitos previos..."

# Flutter
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado. Instala Flutter primero."
    exit 1
fi
print_success "Flutter encontrado: $(flutter --version | head -n 1)"

# Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js no está instalado. Instala Node.js primero."
    exit 1
fi
print_success "Node.js encontrado: $(node --version)"

# npm
if ! command -v npm &> /dev/null; then
    print_error "npm no está instalado. Instala npm primero."
    exit 1
fi
print_success "npm encontrado: $(npm --version)"

# Git
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado. Instala Git primero."
    exit 1
fi
print_success "Git encontrado: $(git --version)"

# Instalar dependencias Flutter
print_status "Instalando dependencias Flutter..."
flutter clean
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependencias Flutter instaladas"
else
    print_error "Error instalando dependencias Flutter"
    exit 1
fi

# Instalar dependencias Node.js
print_status "Instalando dependencias Node.js..."
npm install
if [ $? -eq 0 ]; then
    print_success "Dependencias Node.js instaladas"
else
    print_error "Error instalando dependencias Node.js"
    exit 1
fi

# Verificar que los archivos principales existen
print_status "Verificando archivos principales..."

REQUIRED_FILES=(
    "lib/main.dart"
    "mock_backend.js"
    "websocket_server.js"
    "facturacion_server.js"
    "start_all.sh"
    "package.json"
    "pubspec.yaml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Archivo requerido no encontrado: $file"
        exit 1
    fi
done
print_success "Todos los archivos principales encontrados"

# Hacer ejecutables los scripts
print_status "Configurando permisos de ejecución..."
chmod +x start_all.sh
chmod +x start_dashboard.sh
chmod +x start_facturacion_demo.sh
chmod +x stop_all.sh
chmod +x build_apk.sh
print_success "Permisos configurados"

# Crear directorio de logs si no existe
mkdir -p logs
print_success "Directorio de logs creado"

# Verificar puertos disponibles
print_status "Verificando puertos disponibles..."

PORTS=(8082 8083 8084 8085)
for port in "${PORTS[@]}"; do
    if lsof -i :$port &> /dev/null; then
        print_warning "Puerto $port está en uso. Puede causar conflictos."
    else
        print_success "Puerto $port disponible"
    fi
done

# Crear archivo de configuración
print_status "Creando archivo de configuración..."
cat > config.env << EOF
# Configuración del Parquímetro Flutter - FINAL1
BACKEND_PORT=8082
WEBSOCKET_PORT=8083
FACTURACION_PORT=8084
DASHBOARD_PORT=8085

# Configuración de la app
APP_NAME=Parquímetro Flutter
APP_VERSION=1.0.0
APP_ENVIRONMENT=production

# Configuración de base de datos
DB_TYPE=json
DB_PATH=./mock_data.json

# Configuración de logs
LOG_LEVEL=info
LOG_FILE=./logs/app.log
EOF
print_success "Archivo de configuración creado"

# Crear script de inicio rápido
print_status "Creando script de inicio rápido..."
cat > run_complete_system.sh << 'EOF'
#!/bin/bash

echo "🚀 INICIANDO SISTEMA COMPLETO DEL PARQUÍMETRO"
echo "=============================================="

# Función para limpiar procesos al salir
cleanup() {
    echo "🛑 Deteniendo todos los servicios..."
    pkill -f mock_backend.js
    pkill -f websocket_server.js
    pkill -f facturacion_server.js
    pkill -f flutter
    exit 0
}

# Capturar Ctrl+C
trap cleanup SIGINT

# Iniciar backend
echo "📡 Iniciando backend..."
node mock_backend.js &
BACKEND_PID=$!

# Esperar un poco
sleep 2

# Iniciar WebSocket
echo "🔌 Iniciando WebSocket..."
node websocket_server.js &
WEBSOCKET_PID=$!

# Esperar un poco
sleep 2

# Iniciar servidor de facturación
echo "🧾 Iniciando servidor de facturación..."
node facturacion_server.js &
FACTURACION_PID=$!

# Esperar un poco
sleep 2

# Iniciar Flutter
echo "📱 Iniciando Flutter app..."
flutter run -d linux &
FLUTTER_PID=$!

echo "✅ Sistema completo iniciado!"
echo "🌐 Backend: http://localhost:8082"
echo "🔌 WebSocket: ws://localhost:8083"
echo "🧾 Facturación: http://localhost:8084"
echo "📊 Dashboard: http://localhost:8085"
echo ""
echo "Presiona Ctrl+C para detener todos los servicios"

# Esperar a que termine Flutter
wait $FLUTTER_PID
EOF

chmod +x run_complete_system.sh
print_success "Script de inicio rápido creado"

# Crear script de verificación del sistema
print_status "Creando script de verificación..."
cat > verify_system.sh << 'EOF'
#!/bin/bash

echo "🔍 VERIFICANDO SISTEMA DEL PARQUÍMETRO"
echo "======================================"

# Verificar Flutter
echo "📱 Verificando Flutter..."
if flutter doctor &> /dev/null; then
    echo "✅ Flutter OK"
else
    echo "❌ Flutter con problemas"
fi

# Verificar Node.js
echo "📦 Verificando Node.js..."
if node --version &> /dev/null; then
    echo "✅ Node.js OK: $(node --version)"
else
    echo "❌ Node.js no encontrado"
fi

# Verificar dependencias
echo "📚 Verificando dependencias..."
if [ -d "node_modules" ]; then
    echo "✅ Dependencias Node.js instaladas"
else
    echo "❌ Dependencias Node.js faltantes"
fi

if [ -d ".dart_tool" ]; then
    echo "✅ Dependencias Flutter instaladas"
else
    echo "❌ Dependencias Flutter faltantes"
fi

# Verificar archivos principales
echo "📁 Verificando archivos..."
FILES=("lib/main.dart" "mock_backend.js" "websocket_server.js" "facturacion_server.js")
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file faltante"
    fi
done

echo "🎯 Verificación completada"
EOF

chmod +x verify_system.sh
print_success "Script de verificación creado"

# Mostrar resumen final
print_success "🎉 INSTALACIÓN COMPLETADA EXITOSAMENTE!"
echo ""
echo "📋 RESUMEN DE LA INSTALACIÓN:"
echo "=============================="
echo "✅ Rama FINAL1 activa"
echo "✅ Dependencias Flutter instaladas"
echo "✅ Dependencias Node.js instaladas"
echo "✅ Scripts de inicio configurados"
echo "✅ Archivos de configuración creados"
echo ""
echo "🚀 COMANDOS DISPONIBLES:"
echo "========================"
echo "• ./run_complete_system.sh    - Iniciar sistema completo"
echo "• ./start_all.sh              - Iniciar con script original"
echo "• ./verify_system.sh          - Verificar instalación"
echo "• flutter run -d linux         - Solo Flutter"
echo "• node mock_backend.js        - Solo backend"
echo ""
echo "📚 DOCUMENTACIÓN:"
echo "=================="
echo "• README_FINAL1.md            - Documentación completa"
echo "• PLAN_MEJORAS_PARQUIMETRO_2025.md - Plan de mejoras"
echo ""
echo "🌍 ¡El proyecto está listo para usar en cualquier PC del mundo!"
echo ""
print_success "Instalación finalizada. ¡Disfruta del parquímetro! 🚀"
