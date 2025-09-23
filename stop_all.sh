#!/bin/bash

echo "🛑 Deteniendo Sistema Completo MEYPARK"
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

# Función para detener proceso por PID
stop_by_pid() {
    local pid_file=$1
    local service_name=$2
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            print_status "Deteniendo $service_name (PID: $pid)..."
            kill -TERM "$pid" 2>/dev/null
            sleep 2
            if kill -0 "$pid" 2>/dev/null; then
                print_warning "Forzando detención de $service_name..."
                kill -KILL "$pid" 2>/dev/null
            fi
            print_success "$service_name detenido"
        else
            print_warning "$service_name ya estaba detenido"
        fi
        rm -f "$pid_file"
    else
        print_warning "No se encontró PID file para $service_name"
    fi
}

# Función para detener procesos por nombre
stop_by_name() {
    local process_name=$1
    local service_name=$2
    
    local pids=$(pgrep -f "$process_name" 2>/dev/null)
    if [ -n "$pids" ]; then
        print_status "Deteniendo $service_name..."
        echo "$pids" | xargs kill -TERM 2>/dev/null
        sleep 2
        # Verificar si aún están corriendo y forzar detención
        local remaining_pids=$(pgrep -f "$process_name" 2>/dev/null)
        if [ -n "$remaining_pids" ]; then
            print_warning "Forzando detención de $service_name..."
            echo "$remaining_pids" | xargs kill -KILL 2>/dev/null
        fi
        print_success "$service_name detenido"
    else
        print_warning "$service_name no estaba ejecutándose"
    fi
}

# Función para detener procesos por puerto
stop_by_port() {
    local port=$1
    local service_name=$2
    
    local pids=$(lsof -ti:$port 2>/dev/null)
    if [ -n "$pids" ]; then
        print_status "Deteniendo $service_name (puerto $port)..."
        echo "$pids" | xargs kill -TERM 2>/dev/null
        sleep 2
        # Verificar si aún están corriendo y forzar detención
        local remaining_pids=$(lsof -ti:$port 2>/dev/null)
        if [ -n "$remaining_pids" ]; then
            print_warning "Forzando detención de $service_name..."
            echo "$remaining_pids" | xargs kill -KILL 2>/dev/null
        fi
        print_success "$service_name detenido"
    else
        print_warning "$service_name no estaba ejecutándose en puerto $port"
    fi
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
    print_status "Deteniendo todos los servicios de MEYPARK..."
    echo ""
    
    # Detener por PID files (más preciso)
    stop_by_pid "facturacion.pid" "Servidor de Facturación"
    stop_by_pid "mock_backend.pid" "Mock Backend"
    stop_by_pid "websocket.pid" "Servidor WebSocket"
    stop_by_pid "web_server.pid" "Servidor Web"
    stop_by_pid "flutter.pid" "Aplicación Flutter"
    
    # Detener por nombre de proceso (por si acaso)
    stop_by_name "node.*facturacion_server.js" "Servidor de Facturación"
    stop_by_name "node.*mock_backend.js" "Mock Backend"
    stop_by_name "node.*websocket_server.js" "Servidor WebSocket"
    stop_by_name "python.*-m.*http.server" "Servidor Web"
    stop_by_name "flutter run" "Aplicación Flutter"
    
    # Detener por puerto (último recurso)
    stop_by_port 8082 "Mock Backend"
    stop_by_port 3002 "Servidor de Facturación"
    stop_by_port 3003 "Servidor WebSocket"
    stop_by_port 8080 "Servidor Web"
    
    # Limpiar archivos temporales
    cleanup_temp_files
    
    echo ""
    print_success "🎉 Todos los servicios de MEYPARK han sido detenidos!"
    echo ""
}

# Ejecutar función principal
main "$@"
