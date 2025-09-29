#!/bin/bash

# 🚀 MEYPARK - Lanzador Manual con Logs Visibles
# =============================================
# Lanza cada servicio en su propia terminal para ver logs en tiempo real

echo "🚀 MEYPARK - Lanzador Manual con Logs Visibles"
echo "=============================================="
echo ""
echo "📋 Servicios disponibles:"
echo "1. Backend Mock (puerto 8082)"
echo "2. WebSocket Server (puerto 3003)" 
echo "3. Servidor Facturación (puerto 3002)"
echo "4. Servidor Web (puerto 8080)"
echo "5. Flutter Linux (con hot reload)"
echo "6. Lanzar TODOS automáticamente"
echo "7. Salir"
echo ""

# Función para matar procesos existentes
kill_existing() {
    echo "🛑 Deteniendo procesos existentes..."
    pkill -f "node.*mock_backend.js" 2>/dev/null || true
    pkill -f "node.*websocket_server.js" 2>/dev/null || true
    pkill -f "node.*facturacion_server.js" 2>/dev/null || true
    pkill -f "python.*-m.*http.server" 2>/dev/null || true
    pkill -f "flutter run" 2>/dev/null || true
    sleep 2
    echo "✅ Procesos detenidos"
}

# Función para verificar puerto
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Función para lanzar Backend Mock
start_backend() {
    echo "🔧 Iniciando Backend Mock (puerto 8082)..."
    if check_port 8082; then
        echo "⚠️  Puerto 8082 ya está en uso"
        lsof -ti:8082 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    echo "📡 Ejecutando: node mock_backend.js"
    echo "💡 Presiona Ctrl+C para detener"
    echo "----------------------------------------"
    node mock_backend.js
}

# Función para lanzar WebSocket
start_websocket() {
    echo "🔌 Iniciando WebSocket Server (puerto 3003)..."
    if check_port 3003; then
        echo "⚠️  Puerto 3003 ya está en uso"
        lsof -ti:3003 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    echo "📡 Ejecutando: node websocket_server.js"
    echo "💡 Presiona Ctrl+C para detener"
    echo "----------------------------------------"
    node websocket_server.js
}

# Función para lanzar Facturación
start_facturacion() {
    echo "🧾 Iniciando Servidor Facturación (puerto 3002)..."
    if check_port 3002; then
        echo "⚠️  Puerto 3002 ya está en uso"
        lsof -ti:3002 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    echo "📡 Ejecutando: node facturacion_server.js"
    echo "💡 Presiona Ctrl+C para detener"
    echo "----------------------------------------"
    node facturacion_server.js
}

# Función para lanzar Servidor Web
start_web() {
    echo "🌐 Iniciando Servidor Web (puerto 8080)..."
    if check_port 8080; then
        echo "⚠️  Puerto 8080 ya está en uso"
        lsof -ti:8080 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    echo "📡 Ejecutando: python3 -m http.server 8080 (en directorio web/)"
    echo "💡 Presiona Ctrl+C para detener"
    echo "----------------------------------------"
    cd web
    python3 -m http.server 8080
    cd ..
}

# Función para lanzar Flutter
start_flutter() {
    echo "📱 Iniciando Flutter Linux con Hot Reload..."
    
    # Verificar dispositivos
    local devices=$(flutter devices --machine | grep -c '"id"')
    if [ $devices -eq 0 ]; then
        echo "❌ No hay dispositivos Flutter disponibles"
        return 1
    fi
    
    echo "📡 Ejecutando: flutter run -d linux"
    echo "💡 Presiona 'r' para hot reload, 'R' para hot restart, 'q' para salir"
    echo "----------------------------------------"
    flutter run -d linux
}

# Función para lanzar todos automáticamente
start_all_auto() {
    echo "🚀 Lanzando TODOS los servicios automáticamente..."
    echo "💡 Cada servicio se ejecutará en background"
    echo ""
    
    # Backend Mock
    echo "1️⃣ Iniciando Backend Mock..."
    nohup node mock_backend.js > mock_backend.log 2>&1 &
    echo $! > mock_backend.pid
    sleep 2
    
    # WebSocket
    echo "2️⃣ Iniciando WebSocket..."
    nohup node websocket_server.js > websocket.log 2>&1 &
    echo $! > websocket.pid
    sleep 2
    
    # Facturación
    echo "3️⃣ Iniciando Facturación..."
    nohup node facturacion_server.js > facturacion.log 2>&1 &
    echo $! > facturacion.pid
    sleep 2
    
    # Web Server
    echo "4️⃣ Iniciando Web Server..."
    cd web
    nohup python3 -m http.server 8080 > ../web_server.log 2>&1 &
    echo $! > ../web_server.pid
    cd ..
    sleep 2
    
    # Flutter
    echo "5️⃣ Iniciando Flutter..."
    nohup flutter run -d linux > flutter.log 2>&1 &
    echo $! > flutter.pid
    
    echo ""
    echo "✅ Todos los servicios iniciados en background"
    echo "📊 Estado de servicios:"
    echo "  • Backend Mock: http://localhost:8082"
    echo "  • WebSocket: ws://localhost:3003"
    echo "  • Facturación: http://localhost:3002"
    echo "  • Web Server: http://localhost:8080"
    echo "  • Flutter: Ejecutándose"
    echo ""
    echo "📋 Para ver logs:"
    echo "  • tail -f mock_backend.log"
    echo "  • tail -f websocket.log"
    echo "  • tail -f facturacion.log"
    echo "  • tail -f web_server.log"
    echo "  • tail -f flutter.log"
    echo ""
    echo "🛑 Para detener todo: ./stop_all.sh"
}

# Menú principal
while true; do
    echo ""
    echo "🎯 ¿Qué servicio quieres lanzar?"
    read -p "Ingresa el número (1-7): " choice
    
    case $choice in
        1)
            kill_existing
            start_backend
            ;;
        2)
            kill_existing
            start_websocket
            ;;
        3)
            kill_existing
            start_facturacion
            ;;
        4)
            kill_existing
            start_web
            ;;
        5)
            kill_existing
            start_flutter
            ;;
        6)
            kill_existing
            start_all_auto
            ;;
        7)
            echo "👋 ¡Hasta luego!"
            exit 0
            ;;
        *)
            echo "❌ Opción inválida. Ingresa un número del 1 al 7."
            ;;
    esac
    
    echo ""
    echo "🔄 ¿Quieres lanzar otro servicio? (y/n)"
    read -p "Respuesta: " continue_choice
    if [[ $continue_choice != "y" && $continue_choice != "Y" ]]; then
        echo "👋 ¡Hasta luego!"
        break
    fi
done
