const WebSocket = require('ws');
const http = require('http');
const fs = require('fs');
const path = require('path');

// ========================================
// DATOS CENTRALIZADOS (SIMULANDO BASE DE DATOS)
// ========================================

let mockData = {};

// Cargar datos desde archivo JSON
function loadData() {
  try {
    const dataPath = path.join(__dirname, 'mock_data.json');
    const geoKiosksPath = path.join(__dirname, 'geographic_kiosks.json');
    
    if (fs.existsSync(dataPath)) {
      const data = fs.readFileSync(dataPath, 'utf8');
      mockData = JSON.parse(data);
      console.log('📂 Datos cargados desde mock_data.json');
      
      // Cargar kioskos geográficos si existe el archivo
      if (fs.existsSync(geoKiosksPath)) {
        try {
          const geoKiosksData = fs.readFileSync(geoKiosksPath, 'utf8');
          const geoKiosks = JSON.parse(geoKiosksData);
          
          // Reemplazar kioskos existentes con los geográficos
          mockData.parkingMeters = geoKiosks;
          console.log('🏢 Kioskos geográficos cargados:', Object.keys(geoKiosks).length);
        } catch (error) {
          console.log('⚠️ Error cargando kioskos geográficos:', error.message);
        }
      }
    } else {
      console.log('⚠️ Archivo mock_data.json no encontrado, usando datos por defecto');
      initializeDefaultData();
    }
  } catch (error) {
    console.error('❌ Error cargando datos:', error.message);
    initializeDefaultData();
  }
}

// Inicializar datos por defecto si no hay archivo
function initializeDefaultData() {
  mockData = {
    companies: {
      'mowiz-company': {
        id: 'mowiz-company',
        name: 'MOWIZ',
        contact: 'info@mowiz.com',
        phone: '+34 900 123 456',
        address: 'Madrid, España',
        createdAt: '2025-01-01T00:00:00.000Z'
      },
      'eypsa-company': {
        id: 'eypsa-company',
        name: 'EYPSA',
        contact: 'info@eypsa.com',
        phone: '+34 900 789 012',
        address: 'Barcelona, España',
        createdAt: '2025-01-01T00:00:00.000Z'
      }
    },
    operators: {
      'mowiz-admin': {
        id: 'mowiz-admin',
        companyId: 'mowiz-company',
        name: 'MOWIZ Admin',
        username: 'mowiz_admin',
        password: 'Mo2025!',
        role: 'admin',
        permissions: ['all'],
        createdAt: '2025-01-01T00:00:00.000Z'
      },
      'eypsa-admin': {
        id: 'eypsa-admin',
        companyId: 'eypsa-company',
        name: 'EYPSA Admin',
        username: 'eypsa_admin',
        password: 'Ey2025!',
        role: 'admin',
        permissions: ['all'],
        createdAt: '2025-01-01T00:00:00.000Z'
      }
    },
    zones: {},
    activeSessions: {},
    stats: {
      totalIncome: 0,
      todayIncome: 0,
      activeSessions: 0,
      totalCompanies: 0,
      totalZones: 0,
      totalOperators: 0
    },
    techDiagnostics: {
      network: true,
      printer: true,
      display: true,
      touch: true,
      coins: true,
      cards: true,
      lastUpdate: new Date().toISOString()
    },
    accessibility: {
      darkMode: false,
      highContrast: false,
      fontSize: 'normal',
      reduceAnimations: false,
      voiceGuide: false,
      voiceSpeed: 0.5,
      voicePitch: 1.0,
      voiceVolume: 0.8,
      adaptiveAI: false,
      simplifiedMode: false,
      currentLanguage: 'es-ES'
    },
    paymentConfig: {
      acceptedCoins: [0.05, 0.10, 0.20, 0.50, 1.00, 2.00],
      acceptedCards: ['Visa', 'Mastercard', 'American Express'],
      maxChangeAmount: 10.0,
      minPaymentAmount: 0.15,
      currency: 'EUR',
      symbol: '€'
    },
    kioscoConfig: {
      id: '',
      location: 'Centro Comercial',
      timezone: 'Europe/Madrid',
      maintenanceMode: false,
      lastRestart: new Date().toISOString()
    }
  };
}

// Cargar datos al iniciar
loadData();

// ========================================
// FUNCIONES DE PERSISTENCIA
// ========================================

function saveData() {
  try {
    const dataPath = path.join(__dirname, 'mock_data.json');
    fs.writeFileSync(dataPath, JSON.stringify(mockData, null, 2));
    console.log('💾 Datos guardados en mock_data.json');
  } catch (error) {
    console.error('❌ Error guardando datos:', error.message);
  }
}

// ========================================
// FUNCIONES DE GESTIÓN DE DATOS
// ========================================

function getAllData() {
  return {
    companies: mockData.companies || {},
    operators: mockData.operators || {},
    zones: mockData.zones || {},
    activeSessions: mockData.activeSessions || {},
    stats: mockData.stats || {},
    techDiagnostics: mockData.techDiagnostics || {},
    accessibility: mockData.accessibility || {},
    paymentConfig: mockData.paymentConfig || {},
    kioscoConfig: mockData.kioscoConfig || {},
    parkingMeters: mockData.parkingMeters || {}
  };
}

function updateCompany(companyId, updates) {
  if (mockData.companies[companyId]) {
    mockData.companies[companyId] = { ...mockData.companies[companyId], ...updates };
    saveData();
    return { success: true, company: mockData.companies[companyId] };
  }
  return { success: false, error: 'Empresa no encontrada' };
}

function updateZone(zoneId, updates) {
  if (mockData.zones[zoneId]) {
    mockData.zones[zoneId] = { ...mockData.zones[zoneId], ...updates };
    mockData.stats.totalZones = Object.keys(mockData.zones).length;
    saveData();
    return { success: true, zone: mockData.zones[zoneId] };
  }
  return { success: false, error: 'Zona no encontrada' };
}

function deleteZone(zoneId) {
  if (mockData.zones[zoneId]) {
    delete mockData.zones[zoneId];
    mockData.stats.totalZones = Object.keys(mockData.zones).length;
    saveData();
    return { success: true };
  }
  return { success: false, error: 'Zona no encontrada' };
}

function updateOperator(operatorId, updates) {
  if (mockData.operators[operatorId]) {
    mockData.operators[operatorId] = { ...mockData.operators[operatorId], ...updates };
    mockData.stats.totalOperators = Object.keys(mockData.operators).length;
    saveData();
    return { success: true, operator: mockData.operators[operatorId] };
  }
  return { success: false, error: 'Operador no encontrado' };
}

function updateAccessibility(updates) {
  mockData.accessibility = { ...mockData.accessibility, ...updates };
  saveData();
  return { success: true, accessibility: mockData.accessibility };
}

function updateStats(updates) {
  mockData.stats = { ...mockData.stats, ...updates };
  saveData();
  return { success: true, stats: mockData.stats };
}

function updateTechDiagnostics(updates) {
  mockData.techDiagnostics = { ...mockData.techDiagnostics, ...updates, lastUpdate: new Date().toISOString() };
  saveData();
  return { success: true, techDiagnostics: mockData.techDiagnostics };
}

function addSession(sessionId, session) {
  // Mantener fechas en formato ISO para compatibilidad con Flutter
  mockData.activeSessions[sessionId] = session;
  mockData.stats.activeSessions = Object.keys(mockData.activeSessions).length;
  saveData();
  console.log(`🅿️ Sesión agregada: ${session.plate} (UTC: ${session.start} - ${session.end})`);
  return { success: true, session: session };
}

function updateSession(sessionId, session) {
  if (mockData.activeSessions[sessionId]) {
    mockData.activeSessions[sessionId] = session;
    saveData();
    console.log(`🔄 Sesión actualizada: ${session.plate}`);
    return { success: true, session: session };
  } else {
    console.log(`❌ Sesión no encontrada para actualizar: ${sessionId}`);
    return { success: false, message: 'Sesión no encontrada' };
  }
}

function extendSession(plate, extraMinutes, extraPrice) {
  // Buscar sesión por matrícula
  let sessionToExtend = null;
  let sessionId = null;
  
  for (const [id, session] of Object.entries(mockData.activeSessions)) {
    if (session.plate === plate) {
      sessionToExtend = session;
      sessionId = id;
      break;
    }
  }
  
  if (!sessionToExtend) {
    console.log(`❌ Sesión no encontrada para extender: ${plate}`);
    return { success: false, message: 'Sesión no encontrada' };
  }
  
  // Obtener zona para validar límites
  const zone = mockData.zones[sessionToExtend.zoneId];
  if (!zone) {
    console.log(`❌ Zona no encontrada: ${sessionToExtend.zoneId}`);
    return { success: false, message: 'Zona no encontrada' };
  }
  
  // Calcular tiempo actual de la sesión
  const startTime = new Date(sessionToExtend.start);
  const endTime = new Date(sessionToExtend.end);
  const currentDurationMinutes = Math.floor((endTime - startTime) / (1000 * 60));
  
  // Validar límite máximo de la zona
  const maxDurationMinutes = zone.maxDuration;
  const newTotalMinutes = currentDurationMinutes + extraMinutes;
  
  if (newTotalMinutes > maxDurationMinutes) {
    console.log(`❌ Extensión excede límite de zona: ${newTotalMinutes}min > ${maxDurationMinutes}min`);
    return { 
      success: false, 
      message: `No se puede extender más. Máximo de zona: ${maxDurationMinutes}min. Quedan: ${maxDurationMinutes - currentDurationMinutes}min`,
      maxAllowed: maxDurationMinutes - currentDurationMinutes
    };
  }
  
  // Extender sesión
  const newEndTime = new Date(endTime.getTime() + (extraMinutes * 60 * 1000));
  const extendedSession = {
    ...sessionToExtend,
    end: newEndTime.toISOString(),
    totalPrice: sessionToExtend.totalPrice + extraPrice
  };
  
  mockData.activeSessions[sessionId] = extendedSession;
  saveData();
  
  console.log(`⏰ Sesión extendida: ${plate} +${extraMinutes}min (total: ${newTotalMinutes}min/${maxDurationMinutes}min)`);
  return { success: true, session: extendedSession };
}

// Función para limpiar sesiones expiradas
function cleanExpiredSessions() {
  const now = new Date();
  let cleanedCount = 0;
  
  for (const [sessionId, session] of Object.entries(mockData.activeSessions)) {
    // Convertir hora de España a UTC para comparar
    const endTime = new Date(session.end);
    if (endTime < now) {
      delete mockData.activeSessions[sessionId];
      cleanedCount++;
      console.log(`🗑️ Sesión expirada eliminada: ${session.plate} (expiró: ${endTime.toLocaleString('es-ES', { timeZone: 'Europe/Madrid' })})`);
    }
  }
  
  if (cleanedCount > 0) {
    mockData.stats.activeSessions = Object.keys(mockData.activeSessions).length;
    saveData();
    console.log(`🧹 Limpieza completada: ${cleanedCount} sesiones expiradas eliminadas`);
  }
  
  return cleanedCount;
}

function removeSession(sessionId) {
  if (mockData.activeSessions[sessionId]) {
    delete mockData.activeSessions[sessionId];
    mockData.stats.activeSessions = Object.keys(mockData.activeSessions).length;
    saveData();
    return { success: true };
  }
  return { success: false, error: 'Sesión no encontrada' };
}

// ========================================
// FUNCIONES DE GESTIÓN DE PARKÍMETROS
// ========================================

function updateParkingMeter(meterId, updates) {
  if (mockData.parkingMeters && mockData.parkingMeters[meterId]) {
    mockData.parkingMeters[meterId] = { ...mockData.parkingMeters[meterId], ...updates };
    mockData.parkingMeters[meterId].lastConnection = new Date().toISOString();
    saveData();
    return { success: true };
  }
  return { success: false, error: 'Parkímetro no encontrado' };
}

function assignCompanyToMeter(meterId, companyId, operatorId) {
  if (mockData.parkingMeters && mockData.parkingMeters[meterId]) {
    mockData.parkingMeters[meterId].assignedCompany = companyId;
    mockData.parkingMeters[meterId].assignedOperator = operatorId;
    mockData.parkingMeters[meterId].lastConnection = new Date().toISOString();
    saveData();
    return { success: true };
  }
  return { success: false, error: 'Parkímetro no encontrado' };
}

function updateMeterStatus(meterId, status, hardwareStatus = null) {
  if (mockData.parkingMeters && mockData.parkingMeters[meterId]) {
    mockData.parkingMeters[meterId].status = status;
    mockData.parkingMeters[meterId].lastConnection = new Date().toISOString();
    
    if (hardwareStatus) {
      mockData.parkingMeters[meterId].hardwareStatus = { ...mockData.parkingMeters[meterId].hardwareStatus, ...hardwareStatus };
    }
    
    saveData();
    return { success: true };
  }
  return { success: false, error: 'Parkímetro no encontrado' };
}

function updateMeterScreen(meterId, screen) {
  if (mockData.parkingMeters && mockData.parkingMeters[meterId]) {
    mockData.parkingMeters[meterId].currentScreen = screen;
    mockData.parkingMeters[meterId].lastConnection = new Date().toISOString();
    saveData();
    return { success: true };
  }
  return { success: false, error: 'Parkímetro no encontrado' };
}

function addMeterError(meterId, error) {
  if (mockData.parkingMeters && mockData.parkingMeters[meterId]) {
    mockData.parkingMeters[meterId].lastError = {
      code: error.code,
      message: error.message,
      timestamp: new Date().toISOString()
    };
    mockData.parkingMeters[meterId].status = 'error';
    saveData();
    return { success: true };
  }
  return { success: false, error: 'Parkímetro no encontrado' };
}

function getParkingMeter(meterId) {
  if (mockData.parkingMeters && mockData.parkingMeters[meterId]) {
    return { success: true, meter: mockData.parkingMeters[meterId] };
  }
  return { success: false, error: 'Parkímetro no encontrado' };
}

// ========================================
// SERVIDOR HTTP
// ========================================

const server = http.createServer((req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);
  
  if (url.pathname === '/api/data' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(getAllData()));
  } else if (url.pathname === '/api/companies' && req.method === 'PUT') {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const result = updateCompany(data.id, data.updates);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: error.message }));
      }
    });
  } else if (url.pathname === '/api/zones' && req.method === 'PUT') {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const result = updateZone(data.id, data.updates);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: error.message }));
      }
    });
  } else if (url.pathname === '/api/zones' && req.method === 'DELETE') {
    const zoneId = url.searchParams.get('id');
    const result = deleteZone(zoneId);
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(result));
  } else if (url.pathname === '/api/parking-meters' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ success: true, meters: mockData.parkingMeters || {} }));
  } else if (url.pathname === '/api/parking-meters' && req.method === 'PUT') {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const result = updateParkingMeter(data.id, data.updates);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: error.message }));
      }
    });
  } else if (url.pathname === '/api/parking-meters/assign-company' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const result = assignCompanyToMeter(data.meterId, data.companyId, data.operatorId);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: error.message }));
      }
    });
  } else if (url.pathname === '/api/parking-meters/status' && req.method === 'PUT') {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const result = updateMeterStatus(data.meterId, data.status, data.hardwareStatus);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: error.message }));
      }
    });
  } else if (url.pathname === '/api/parking-meters/screen' && req.method === 'PUT') {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const result = updateMeterScreen(data.meterId, data.screen);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: error.message }));
      }
    });
  } else if (url.pathname === '/api/commands' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const { meterId, command, data: commandData } = data;
        
        if (!meterId || !command) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ success: false, error: 'meterId y command son requeridos' }));
          return;
        }
        
        const meter = mockData.parkingMeters?.[meterId];
        if (!meter) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ success: false, error: 'Parkímetro no encontrado' }));
          return;
        }
        
        // Procesar comando
        let result = { success: true, message: 'Comando procesado' };
        
        switch (command) {
          case 'restart':
            result.message = 'Comando de reinicio enviado';
            break;
          case 'update_config':
            result.message = 'Configuración actualizada';
            break;
          case 'sync_data':
            result.message = 'Datos sincronizados';
            break;
          case 'test_connection':
            result.message = 'Test de conexión ejecutado';
            break;
          case 'assign_zone':
            result.message = `Zona ${commandData?.zoneName || 'desconocida'} asignada`;
            break;
          default:
            result.message = `Comando ${command} ejecutado`;
        }
        
        // Actualizar última conexión
        meter.lastConnection = new Date().toISOString();
        saveData();
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: error.message }));
      }
    });
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Endpoint no encontrado' }));
  }
});

// ========================================
// SERVIDOR WEBSOCKET
// ========================================

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('🔌 Cliente conectado al backend centralizado');
  
  // ID será asignado cuando se reciba el mensaje de registro
  let connectionId = `kiosco-${Date.now()}`;
  
  // Enviar datos completos al conectar
  ws.send(JSON.stringify({
    type: 'full_data',
    data: getAllData()
  }));

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      
      switch (data.type) {
        case 'get_data':
          ws.send(JSON.stringify({
            type: 'full_data',
            data: getAllData()
          }));
          break;
          
        case 'update_company':
          const companyResult = updateCompany(data.companyId, data.updates);
          ws.send(JSON.stringify({ type: 'company_updated', ...companyResult }));
          broadcast({ type: 'company_updated', ...companyResult });
          break;
          
        case 'update_zone':
          const zoneResult = updateZone(data.zoneId, data.updates);
          ws.send(JSON.stringify({ type: 'zone_updated', ...zoneResult }));
          broadcast({ type: 'zone_updated', ...zoneResult });
          break;
          
        case 'delete_zone':
          const deleteResult = deleteZone(data.zoneId);
          ws.send(JSON.stringify({ type: 'zone_deleted', ...deleteResult }));
          broadcast({ type: 'zone_deleted', ...deleteResult });
          break;
          
        case 'update_operator':
          const operatorResult = updateOperator(data.operatorId, data.updates);
          ws.send(JSON.stringify({ type: 'operator_updated', ...operatorResult }));
          broadcast({ type: 'operator_updated', ...operatorResult });
          break;
          
        case 'update_accessibility':
          const accessibilityResult = updateAccessibility(data.updates);
          ws.send(JSON.stringify({ type: 'accessibility_updated', ...accessibilityResult }));
          broadcast({ type: 'accessibility_updated', ...accessibilityResult });
          break;
          
        case 'update_stats':
          const statsResult = updateStats(data.updates);
          ws.send(JSON.stringify({ type: 'stats_updated', ...statsResult }));
          broadcast({ type: 'stats_updated', ...statsResult });
          break;
          
        case 'tech_diagnostics':
          const techResult = updateTechDiagnostics(data.diagnostics);
          ws.send(JSON.stringify({ type: 'tech_diagnostics', ...techResult }));
          broadcast({ type: 'tech_diagnostics', ...techResult });
          break;
          
        case 'update_parking_meter':
          const meterResult = updateParkingMeter(data.meterId, data.updates);
          ws.send(JSON.stringify({ type: 'parking_meter_updated', ...meterResult }));
          broadcast({ type: 'parking_meter_updated', ...meterResult });
          break;
          
        case 'assign_company_to_meter':
          const assignResult = assignCompanyToMeter(data.meterId, data.companyId, data.operatorId);
          ws.send(JSON.stringify({ type: 'company_assigned_to_meter', ...assignResult }));
          broadcast({ type: 'company_assigned_to_meter', ...assignResult });
          break;
          
        case 'update_meter_status':
          const statusResult = updateMeterStatus(data.meterId, data.status, data.hardwareStatus);
          ws.send(JSON.stringify({ type: 'meter_status_updated', ...statusResult }));
          broadcast({ type: 'meter_status_updated', ...statusResult });
          break;
          
        case 'update_meter_screen':
          const screenResult = updateMeterScreen(data.meterId, data.screen);
          ws.send(JSON.stringify({ type: 'meter_screen_updated', ...screenResult }));
          broadcast({ type: 'meter_screen_updated', ...screenResult });
          break;
          
        case 'add_meter_error':
          const errorResult = addMeterError(data.meterId, data.error);
          ws.send(JSON.stringify({ type: 'meter_error_added', ...errorResult }));
          broadcast({ type: 'meter_error_added', ...errorResult });
          break;
          
        case 'register_app':
          // Usar el ID que envía la app en lugar del generado automáticamente
          const appId = data.appId || connectionId;
          connectionId = appId; // Actualizar el connectionId
          
          // Registrar la app como parkímetro dinámico
          if (!mockData.parkingMeters) {
            mockData.parkingMeters = {};
          }
          
          mockData.parkingMeters[appId] = {
            id: appId,
            name: data.appInfo.name || `App Flutter - ${new Date().toLocaleTimeString()}`,
            location: data.appInfo.location || 'Aplicación Móvil',
            gps: {
              lat: 40.4168,
              lng: -3.7038
            },
            status: 'online',
            lastConnection: new Date().toISOString(),
            assignedCompany: 'mowiz',
            assignedOperator: 'mowiz_admin',
            currentScreen: 'zone_selection',
            hardwareStatus: {
              display: true,
              touch: true,
              printer: false,
              coins: false,
              cards: true,
              network: true
            },
            currentSession: null,
            totalSessions: 0,
            todayIncome: 0,
            lastError: null,
            version: data.appInfo.version || '1.0.0',
            createdAt: new Date().toISOString(),
            isApp: true
          };
          
          saveData();
          
          console.log(`📱 App ${appId} registrada correctamente`);
          
          // Notificar a otros clientes sobre la nueva app
          broadcast({
            type: 'app_registered',
            meterId: appId,
            appInfo: data.appInfo,
            success: true
          });
          break;
          
        case 'add_session':
          const sessionResult = addSession(data.sessionId, data.session);
          ws.send(JSON.stringify({ type: 'session_added', ...sessionResult }));
          broadcast({ type: 'session_added', ...sessionResult });
          break;
          
        case 'update_session':
          const updateResult = updateSession(data.sessionId, data.session);
          ws.send(JSON.stringify({ type: 'session_updated', ...updateResult }));
          broadcast({ type: 'session_updated', ...updateResult });
          break;
          
        case 'extend_session':
          console.log('⏰ Extendiendo sesión:', data);
          const extendResult = extendSession(data.plate, data.extraMinutes, data.extraPrice);
          ws.send(JSON.stringify({ type: 'session_extended', ...extendResult }));
          broadcast({ type: 'session_extended', ...extendResult });
          break;
          
        case 'remove_session':
          const removeResult = removeSession(data.sessionId);
          ws.send(JSON.stringify({ type: 'session_removed', ...removeResult }));
          broadcast({ type: 'session_removed', ...removeResult });
          break;
          
        case 'search_session':
          console.log('🔍 Mensaje search_session recibido:', data);
          const plate = data?.plate;
          
          if (!plate) {
            console.log('❌ Error: No se proporcionó matrícula en search_session');
            ws.send(JSON.stringify({ 
              type: 'session_found', 
              success: false, 
              message: 'Error: No se proporcionó matrícula',
              plate: null
            }));
            break;
          }
          
          console.log(`🔍 Buscando sesión para matrícula: ${plate}`);
          
          // Buscar sesión por matrícula
          let foundSession = null;
          for (const [sessionId, session] of Object.entries(mockData.activeSessions)) {
            if (session.plate === plate) {
              foundSession = session;
              break;
            }
          }
          
          if (foundSession) {
            console.log(`✅ Sesión encontrada: ${foundSession.plate} en zona ${foundSession.zoneId}`);
            ws.send(JSON.stringify({ 
              type: 'session_found', 
              success: true, 
              session: foundSession,
              plate: plate
            }));
          } else {
            console.log(`❌ No se encontró sesión para matrícula: ${plate}`);
            ws.send(JSON.stringify({ 
              type: 'session_found', 
              success: false, 
              message: 'No hay sesión activa para esta matrícula',
              plate: plate
            }));
          }
          break;
          
        case 'clean_expired':
          console.log('🧹 Limpieza manual de sesiones expiradas solicitada');
          const cleanedCount = cleanExpiredSessions();
          ws.send(JSON.stringify({ 
            type: 'cleanup_completed', 
            success: true, 
            cleanedCount: cleanedCount,
            message: `Limpieza completada: ${cleanedCount} sesiones eliminadas`
          }));
          break;
          
        default:
          ws.send(JSON.stringify({ type: 'error', message: 'Tipo de mensaje no reconocido' }));
      }
    } catch (error) {
      console.error('❌ Error procesando mensaje:', error);
      ws.send(JSON.stringify({ type: 'error', message: error.message }));
    }
  });

  ws.on('close', () => {
    console.log('🔌 Cliente desconectado del backend centralizado');
    
    // Marcar la app como offline si es una app Flutter
    if (mockData.parkingMeters && mockData.parkingMeters[connectionId]) {
      mockData.parkingMeters[connectionId].status = 'offline';
      mockData.parkingMeters[connectionId].lastConnection = new Date().toISOString();
      saveData();
      
      // Notificar a otros clientes que la app se desconectó
      broadcast({
        type: 'app_disconnected',
        meterId: connectionId,
        success: true
      });
      
      console.log(`📱 App Flutter ${connectionId} marcada como offline`);
    }
  });
});

function broadcast(message) {
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(message));
    }
  });
}

// ========================================
// INICIAR SERVIDOR
// ========================================

const PORT = 8082;
server.listen(PORT, () => {
  console.log('🚀 Backend MEYPARK Centralizado iniciado');
  console.log(`📊 Dashboard: http://localhost:${PORT}`);
  console.log(`🔌 WebSocket: ws://localhost:${PORT}`);
  console.log(`📡 API REST: http://localhost:${PORT}/api/`);
  console.log('💾 Datos centralizados en mock_data.json');
  
  // Iniciar limpieza automática de sesiones expiradas cada 5 minutos
  setInterval(() => {
    console.log('🧹 Ejecutando limpieza automática de sesiones expiradas...');
    cleanExpiredSessions();
  }, 5 * 60 * 1000); // 5 minutos
  
  console.log('⏰ Limpieza automática de sesiones configurada (cada 5 minutos)');
  
  // Limpieza inicial al iniciar el servidor
  console.log('🧹 Ejecutando limpieza inicial de sesiones expiradas...');
  cleanExpiredSessions();
});
