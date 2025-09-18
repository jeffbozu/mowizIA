const WebSocket = require('ws');
const http = require('http');
const fs = require('fs');
const path = require('path');

// Crear servidor HTTP
const server = http.createServer((req, res) => {
    // Servir archivos estáticos del dashboard
    if (req.url === '/' || req.url === '/dashboard') {
        const filePath = path.join(__dirname, 'web', 'dashboard.html');
        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.writeHead(404);
                res.end('Dashboard no encontrado');
                return;
            }
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(data);
        });
    } else if (req.url.endsWith('.css')) {
        const filePath = path.join(__dirname, 'web', 'dashboard.css');
        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.writeHead(404);
                res.end('CSS no encontrado');
                return;
            }
            res.writeHead(200, { 'Content-Type': 'text/css' });
            res.end(data);
        });
    } else if (req.url.endsWith('.js')) {
        const filePath = path.join(__dirname, 'web', 'dashboard.js');
        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.writeHead(404);
                res.end('JS no encontrado');
                return;
            }
            res.writeHead(200, { 'Content-Type': 'application/javascript' });
            res.end(data);
        });
    } else {
        res.writeHead(404);
        res.end('Archivo no encontrado');
    }
});

// Crear servidor WebSocket
const wss = new WebSocket.Server({ server });

// Datos simulados del kiosco
let kioskData = {
    status: 'online',
    currentScreen: 'login',
    currentUser: null,
    activeSessions: [],
    diagnostics: {
        network: true,
        printer: true,
        display: true,
        touch: true,
        coins: true,
        cards: true
    },
    stats: {
        totalIncome: 0,
        todayIncome: 0,
        activeSessions: 0,
        totalCompanies: 2,
        totalZones: 4
    }
};

// Clientes conectados
const clients = new Set();

// Función para cargar datos del archivo JSON
function loadData() {
    try {
        const data = fs.readFileSync(path.join(__dirname, 'mock_data.json'), 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error('Error cargando datos:', error);
        return {
            companies: {},
            operators: {},
            zones: {},
            sessions: [],
            stats: {
                totalIncome: 0,
                todayIncome: 0,
                activeSessions: 0,
                totalCompanies: 0,
                totalZones: 0
            }
        };
    }
}

wss.on('connection', (ws) => {
    console.log('Cliente conectado al dashboard');
    clients.add(ws);
    
    // Enviar datos iniciales completos del backend
    const fullData = loadData();
    console.log('📤 Enviando datos iniciales del backend:', {
        companies: Object.keys(fullData.companies || {}).length,
        zones: Object.keys(fullData.zones || {}).length,
        operators: Object.keys(fullData.operators || {}).length,
        activeSessions: Object.keys(fullData.activeSessions || {}).length
    });
    ws.send(JSON.stringify({
        type: 'initial_data',
        data: fullData
    }));
    
    // Enviar estadísticas actualizadas
    ws.send(JSON.stringify({
        type: 'stats_update',
        stats: fullData.stats
    }));
    
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            console.log('📨 Mensaje recibido:', data.type, data);
            handleMessage(ws, data);
        } catch (error) {
            console.error('Error procesando mensaje:', error);
        }
    });
    
    ws.on('close', () => {
        console.log('Cliente desconectado del dashboard');
        clients.delete(ws);
    });
    
    ws.on('error', (error) => {
        console.error('Error WebSocket:', error);
        clients.delete(ws);
    });
});

function handleMessage(ws, data) {
    switch (data.type) {
        case 'get_data':
            // Enviar datos completos del backend
            const fullData = loadData();
            console.log('📤 Enviando datos completos del backend:', {
                companies: Object.keys(fullData.companies || {}).length,
                zones: Object.keys(fullData.zones || {}).length,
                operators: Object.keys(fullData.operators || {}).length,
                activeSessions: Object.keys(fullData.activeSessions || {}).length
            });
            ws.send(JSON.stringify({
                type: 'full_data',
                data: fullData
            }));
            break;
            
        case 'get_stats':
            // Enviar solo estadísticas
            const statsData = loadData();
            ws.send(JSON.stringify({
                type: 'stats_update',
                stats: statsData.stats
            }));
            break;
            
        case 'update_operators':
            // Actualizar operadores en el backend
            if (data.data) {
                const fullData = loadData();
                fullData.operators = data.data;
                // Guardar en archivo (simulado)
                console.log('📝 Operadores actualizados:', data.data);
                ws.send(JSON.stringify({
                    type: 'operators_updated',
                    message: 'Operadores actualizados correctamente'
                }));
            }
            break;
            
        case 'kiosk_status':
            kioskData.status = data.status;
            broadcast({
                type: 'kiosk_status',
                status: data.status
            });
            break;
            
        case 'screen_update':
            kioskData.currentScreen = data.screen;
            kioskData.currentUser = data.user;
            
            // Crear datos de pantalla mejorados
            const screenData = {
                screen: data.screen,
                title: getScreenTitle(data.screen),
                status: 'Activo',
                user: data.user,
                lastAction: data.action || 'Navegación',
                connected: true,
                timestamp: new Date().toISOString(),
                // Datos específicos de la pantalla
                username: data.username || '',
                password: data.password ? '****' : '',
                selectedZone: data.selectedZone || null,
                plate: data.plate || '',
                selectedTime: data.selectedTime || 60,
                total: data.total || '0.00',
                method: data.method || null,
                zone: data.zone || null,
                time: data.time || null
            };
            
            broadcast({
                type: 'kiosk_screen',
                screen: screenData
            });
            break;
            
        case 'session_update':
            updateSession(data.session);
            break;
            
        case 'payment_update':
            updatePayment(data.payment);
            break;
            
        case 'diagnostics_update':
            kioskData.diagnostics = { ...kioskData.diagnostics, ...data.diagnostics };
            broadcast({
                type: 'tech_diagnostics',
                diagnostics: kioskData.diagnostics
            });
            break;
            
        case 'update_company':
            // Enviar actualización de empresa al kiosco
            broadcastToKiosco({
                type: 'update_company',
                data: data.data
            });
            break;
            
        case 'update_zone':
            // Enviar actualización de zona al kiosco
            broadcastToKiosco({
                type: 'update_zone',
                data: data.data
            });
            break;
            
        case 'update_ui':
            // Enviar actualización de UI al kiosco
            broadcastToKiosco({
                type: 'update_ui',
                data: data.data
            });
            break;

        case 'update_operators':
            console.log('👥 Actualizando operadores:', data.data);
            kioskData.operators = data.data;
            broadcastToKiosco({
                type: 'operators_updated',
                data: data.data
            });
            break;
    }
}

function updateSession(session) {
    const existingIndex = kioskData.activeSessions.findIndex(s => s.plate === session.plate);
    
    if (session.status === 'ended') {
        kioskData.activeSessions = kioskData.activeSessions.filter(s => s.plate !== session.plate);
    } else if (existingIndex >= 0) {
        kioskData.activeSessions[existingIndex] = session;
    } else {
        kioskData.activeSessions.push(session);
    }
    
    kioskData.stats.activeSessions = kioskData.activeSessions.length;
    
    broadcast({
        type: 'session_update',
        session: session
    });
}

function updatePayment(payment) {
    kioskData.stats.totalIncome += payment.amount;
    kioskData.stats.todayIncome += payment.amount;
    
    broadcast({
        type: 'payment_update',
        payment: payment
    });
}

function getScreenTitle(screen) {
    const titles = {
        'login': 'Inicio de Sesión',
        'zone': 'Selección de Zona',
        'plate': 'Ingreso de Matrícula',
        'time': 'Tiempo de Estacionamiento',
        'payment': 'Pago',
        'ticket': 'Ticket',
        'extend': 'Extender Sesión',
        'accessibility': 'Accesibilidad',
        'tech': 'Modo Técnico'
    };
    return titles[screen] || 'Pantalla del Kiosco';
}

function broadcast(message) {
    const messageStr = JSON.stringify(message);
    clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(messageStr);
        }
    });
}

function broadcastToKiosco(message) {
    const messageStr = JSON.stringify(message);
    clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            // Solo enviar a clientes que sean kioscos (no dashboards)
            client.send(messageStr);
        }
    });
}

// Simular datos del kiosco cada 5 segundos
setInterval(() => {
    // Simular cambios en diagnósticos
    const diagnostics = { ...kioskData.diagnostics };
    Object.keys(diagnostics).forEach(key => {
        if (Math.random() < 0.1) { // 10% de probabilidad de cambio
            diagnostics[key] = !diagnostics[key];
        }
    });
    
    if (JSON.stringify(diagnostics) !== JSON.stringify(kioskData.diagnostics)) {
        kioskData.diagnostics = diagnostics;
        broadcast({
            type: 'tech_diagnostics',
            diagnostics: diagnostics
        });
    }
    
    // Simular actualización de estadísticas
    broadcast({
        type: 'stats_update',
        stats: kioskData.stats
    });
    
}, 5000);

// Iniciar servidor
const PORT = process.env.PORT || 8080;
server.listen(PORT, () => {
    console.log(`🚀 Servidor MEYPARK Dashboard iniciado en puerto ${PORT}`);
    console.log(`📊 Dashboard disponible en: http://localhost:${PORT}`);
    console.log(`🔌 WebSocket disponible en: ws://localhost:${PORT}`);
    console.log('💡 Para conectar el kiosco, usa el WebSocket en la app Flutter');
});

// Manejo de errores
process.on('uncaughtException', (error) => {
    console.error('Error no capturado:', error);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Promesa rechazada no manejada:', reason);
});
