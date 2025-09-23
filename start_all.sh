#!/bin/bash

echo "🚀 Iniciando Sistema Completo MEYPARK"
echo "======================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes con colores
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

# Función para matar procesos existentes
kill_existing_processes() {
    print_status "Deteniendo procesos existentes..."
    
    # Matar procesos de Flutter
    pkill -f "flutter run" 2>/dev/null || true
    pkill -f "flutter" 2>/dev/null || true
    
    # Matar servidores Node.js
    pkill -f "node.*facturacion_server.js" 2>/dev/null || true
    pkill -f "node.*mock_backend.js" 2>/dev/null || true
    pkill -f "node.*websocket_server.js" 2>/dev/null || true
    
    # Matar servidores web
    pkill -f "python.*-m.*http.server" 2>/dev/null || true
    
    sleep 2
    print_success "Procesos existentes detenidos"
}

# Función para verificar si un puerto está en uso
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # Puerto en uso
    else
        return 1  # Puerto libre
    fi
}

# Función para esperar a que un servicio esté listo
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=0
    
    print_status "Esperando a que $service_name esté listo..."
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            print_success "$service_name está listo!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 1
    done
    
    print_error "$service_name no respondió después de $max_attempts segundos"
    return 1
}

# Función para limpiar y preparar Flutter
prepare_flutter() {
    print_status "Preparando Flutter..."
    
    # Limpiar build
    flutter clean > /dev/null 2>&1
    
    # Obtener dependencias
    flutter pub get > /dev/null 2>&1
    
    print_success "Flutter preparado"
}

# Función para iniciar servidor de facturación
start_facturacion_server() {
    print_status "Iniciando servidor de facturación (puerto 3002)..."
    
    if check_port 3002; then
        print_warning "Puerto 3002 ya está en uso, deteniendo proceso existente..."
        lsof -ti:3002 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    # Iniciar servidor en background
    nohup node facturacion_server.js > facturacion.log 2>&1 &
    local facturacion_pid=$!
    echo $facturacion_pid > facturacion.pid
    
    # Esperar a que esté listo
    if wait_for_service "http://localhost:3002" "Servidor de Facturación"; then
        print_success "Servidor de facturación iniciado (PID: $facturacion_pid)"
    else
        print_error "Error iniciando servidor de facturación"
        return 1
    fi
}

# Función para iniciar servidor mock backend
start_mock_backend() {
    print_status "Iniciando servidor mock backend (puerto 8082)..."
    
    if check_port 8082; then
        print_warning "Puerto 8082 ya está en uso, deteniendo proceso existente..."
        lsof -ti:8082 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    # Iniciar servidor en background
    nohup node mock_backend.js > mock_backend.log 2>&1 &
    local mock_pid=$!
    echo $mock_pid > mock_backend.pid
    
    # Esperar a que esté listo
    if wait_for_service "http://localhost:8082" "Mock Backend"; then
        print_success "Mock backend iniciado (PID: $mock_pid)"
    else
        print_error "Error iniciando mock backend"
        return 1
    fi
}

# Función para iniciar servidor WebSocket
start_websocket_server() {
    print_status "Iniciando servidor WebSocket (puerto 3003)..."
    
    if check_port 3003; then
        print_warning "Puerto 3003 ya está en uso, deteniendo proceso existente..."
        lsof -ti:3003 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    # Iniciar servidor en background
    nohup node websocket_server.js > websocket.log 2>&1 &
    local websocket_pid=$!
    echo $websocket_pid > websocket.pid
    
    print_success "Servidor WebSocket iniciado (PID: $websocket_pid)"
}

# Función para iniciar servidor web estático
start_web_server() {
    print_status "Iniciando servidor web estático (puerto 8080)..."
    
    if check_port 8080; then
        print_warning "Puerto 8080 ya está en uso, deteniendo proceso existente..."
        lsof -ti:8080 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    # Iniciar servidor en background
    cd web
    nohup python3 -m http.server 8080 > ../web_server.log 2>&1 &
    local web_pid=$!
    echo $web_pid > ../web_server.pid
    cd ..
    
    # Esperar a que esté listo
    if wait_for_service "http://localhost:8080" "Servidor Web"; then
        print_success "Servidor web iniciado (PID: $web_pid)"
    else
        print_error "Error iniciando servidor web"
        return 1
    fi
}

# Función para iniciar Flutter
start_flutter() {
    print_status "Iniciando aplicación Flutter..."
    
    # Verificar que hay dispositivos disponibles
    local devices=$(flutter devices --machine | grep -c '"id"')
    if [ $devices -eq 0 ]; then
        print_error "No hay dispositivos Flutter disponibles"
        return 1
    fi
    
    # Iniciar Flutter en background
    nohup flutter run -d linux > flutter.log 2>&1 &
    local flutter_pid=$!
    echo $flutter_pid > flutter.pid
    
    print_success "Flutter iniciado (PID: $flutter_pid)"
    print_status "La aplicación se está compilando, esto puede tomar unos minutos..."
}

# Función para mostrar estado de servicios
show_status() {
    echo ""
    echo "📊 Estado de Servicios:"
    echo "======================"
    
    # Verificar servidores
    if check_port 8082; then
        print_success "✅ Mock Backend (puerto 8082) - ACTIVO"
    else
        print_error "❌ Mock Backend (puerto 8082) - INACTIVO"
    fi
    
    if check_port 3002; then
        print_success "✅ Servidor Facturación (puerto 3002) - ACTIVO"
    else
        print_error "❌ Servidor Facturación (puerto 3002) - INACTIVO"
    fi
    
    if check_port 3003; then
        print_success "✅ WebSocket Server (puerto 3003) - ACTIVO"
    else
        print_error "❌ WebSocket Server (puerto 3003) - INACTIVO"
    fi
    
    if check_port 8080; then
        print_success "✅ Servidor Web (puerto 8080) - ACTIVO"
    else
        print_error "❌ Servidor Web (puerto 8080) - INACTIVO"
    fi
    
    # Verificar Flutter
    if pgrep -f "flutter run" > /dev/null; then
        print_success "✅ Flutter App - ACTIVO"
    else
        print_error "❌ Flutter App - INACTIVO"
    fi
}

# Función para mostrar URLs de acceso
show_urls() {
    echo ""
    echo "🌐 URLs de Acceso:"
    echo "=================="
    echo "• Aplicación Flutter: Ejecutándose en el dispositivo"
    echo "• Dashboard Web: http://localhost:8080/dashboard.html"
    echo "• Facturación Web: http://localhost:8080/facturacion.html"
    echo "• Kiosco Web: http://localhost:8080/kiosco.html"
    echo "• API Mock Backend: http://localhost:8082"
    echo "• API Facturación: http://localhost:3002"
    echo "• WebSocket: ws://localhost:3003"
    echo ""
}

# Función para limpiar archivos temporales
cleanup_temp_files() {
    print_status "Limpiando archivos temporales..."
    rm -f *.pid *.log 2>/dev/null || true
    print_success "Archivos temporales limpiados"
}

# Función principal
main() {
    echo ""
    print_status "Iniciando reinicio completo del sistema MEYPARK..."
    echo ""
    
    # Limpiar procesos existentes
    kill_existing_processes
    
    # Limpiar archivos temporales
    cleanup_temp_files
    
    # Preparar Flutter
    prepare_flutter
    
    # Iniciar servidores en orden
    start_facturacion_server || exit 1
    start_mock_backend || exit 1
    start_websocket_server || exit 1
    start_web_server || exit 1
    
    # Esperar un poco antes de iniciar Flutter
    sleep 3
    
    # Iniciar Flutter
    start_flutter || exit 1
    
    # Mostrar estado
    show_status
    
    # Mostrar URLs
    show_urls
    
    echo ""
    print_success "🎉 Sistema MEYPARK iniciado completamente!"
    print_status "Los logs están disponibles en:"
    echo "  • facturacion.log - Servidor de facturación"
    echo "  • mock_backend.log - Mock backend"
    echo "  • websocket.log - Servidor WebSocket"
    echo "  • web_server.log - Servidor web"
    echo "  • flutter.log - Aplicación Flutter"
    echo ""
    print_status "Para detener todos los servicios, ejecuta: ./stop_all.sh"
    echo ""
}

# Ejecutar función principal
main "$@"