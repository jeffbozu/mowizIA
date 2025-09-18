// MEYPARK Dashboard JavaScript
class MEYPARKDashboard {
    constructor() {
        this.websocket = null;
        this.currentSection = 'overview';
        this.data = {
            companies: [],
            zones: [],
            sessions: [],
            payments: [],
            operators: [],
            kioskStatus: 'offline'
        };
        
        // NO INICIALIZAR CON DATOS LOCALES - TODO DEBE VENIR DEL BACKEND
        this.updateInterval = 5000; // 5 seconds
        this.websocketUrl = 'ws://localhost:8080';
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadSettings();
        this.connectWebSocket();
        this.startDataRefresh();
        this.updateTime();
        
        // Inicializar simulación de pantalla
        this.initKioskSimulation();
    }

    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const section = link.dataset.section;
                this.showSection(section);
            });
        });

        // Modals
        document.getElementById('add-company-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.addCompany();
        });

        document.getElementById('add-zone-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.addZone();
        });

        // Close modals on outside click
        document.querySelectorAll('.modal').forEach(modal => {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeModal(modal.id);
                }
            });
        });
    }

    connectWebSocket() {
        try {
            this.websocket = new WebSocket(this.websocketUrl);
            
            this.websocket.onopen = () => {
                console.log('WebSocket conectado');
                this.updateWebSocketStatus(true);
                this.showToast('Conectado al servidor', 'success');
                
                // Solicitar datos del backend
                this.websocket.send(JSON.stringify({
                    type: 'get_data'
                }));
            };

            this.websocket.onmessage = (event) => {
                const data = JSON.parse(event.data);
                this.handleWebSocketMessage(data);
            };

            this.websocket.onclose = () => {
                console.log('WebSocket desconectado');
                this.updateWebSocketStatus(false);
                this.showToast('Desconectado del servidor', 'error');
                
                // Reconnect after 5 seconds
                setTimeout(() => {
                    this.connectWebSocket();
                }, 5000);
            };

            this.websocket.onerror = (error) => {
                console.error('Error WebSocket:', error);
                this.updateWebSocketStatus(false);
            };
        } catch (error) {
            console.error('Error conectando WebSocket:', error);
            this.updateWebSocketStatus(false);
        }
    }

    handleWebSocketMessage(data) {
        switch (data.type) {
            case 'kiosk_status':
                this.updateKioskStatus(data.status);
                break;
            case 'session_update':
                this.updateSession(data.session);
                break;
            case 'payment_update':
                this.updatePayment(data.payment);
                break;
            case 'kiosk_screen':
                this.updateKioskScreen(data.screen);
                break;
            case 'tech_diagnostics':
                this.updateTechDiagnostics(data.diagnostics);
                break;
            case 'operators_updated':
                this.showToast(data.message || 'Operadores actualizados correctamente', 'success');
                break;
            case 'stats_update':
                this.updateStats(data.stats);
                break;
            case 'full_data':
                this.updateFullData(data.data);
                break;
        }
    }

    updateWebSocketStatus(connected) {
        const statusElement = document.getElementById('websocket-status');
        if (connected) {
            statusElement.className = 'status-item';
            statusElement.innerHTML = '<i class="fas fa-wifi"></i><span>Conectado</span>';
        } else {
            statusElement.className = 'status-item offline';
            statusElement.innerHTML = '<i class="fas fa-wifi"></i><span>Desconectado</span>';
        }
    }

    updateKioskStatus(status) {
        this.data.kioskStatus = status;
        const kioskStatusElement = document.getElementById('kiosk-status');
        const kioskStatusBadge = document.getElementById('kiosk-status-badge');
        
        if (status === 'online') {
            kioskStatusElement.className = 'status-item';
            kioskStatusElement.innerHTML = '<i class="fas fa-desktop"></i><span>Kiosco Online</span>';
            kioskStatusBadge.className = 'badge badge-success';
            kioskStatusBadge.textContent = 'Online';
        } else {
            kioskStatusElement.className = 'status-item offline';
            kioskStatusElement.innerHTML = '<i class="fas fa-desktop"></i><span>Kiosco Offline</span>';
            kioskStatusBadge.className = 'badge badge-danger';
            kioskStatusBadge.textContent = 'Offline';
        }
    }

    updateKioskScreen(screenData) {
        const kioskContent = document.getElementById('kiosk-content');
        
        // Determinar qué pantalla mostrar
        const screen = screenData?.screen || 'login';
        const timestamp = new Date().toLocaleTimeString();
        
        // Simular diferentes pantallas del kiosco
        let screenHTML = '';
        
        switch(screen) {
            case 'login':
                screenHTML = this.renderLoginScreen(screenData);
                break;
            case 'zone':
                screenHTML = this.renderZoneScreen(screenData);
                break;
            case 'plate':
                screenHTML = this.renderPlateScreen(screenData);
                break;
            case 'time':
                screenHTML = this.renderTimeScreen(screenData);
                break;
            case 'payment':
                screenHTML = this.renderPaymentScreen(screenData);
                break;
            case 'ticket':
                screenHTML = this.renderTicketScreen(screenData);
                break;
            default:
                screenHTML = this.renderDefaultScreen(screenData);
        }
        
        kioskContent.innerHTML = `
            <div class="kiosk-screen-simulator">
                <div class="kiosk-topbar">
                    <span class="kiosk-logo">MEYPARK</span>
                    <span class="kiosk-time">${timestamp}</span>
                </div>
                ${screenHTML}
                <div class="kiosk-status">
                    <span class="status-indicator ${screenData?.connected ? 'connected' : 'disconnected'}"></span>
                    <span>${screenData?.user || 'Sin usuario'}</span>
                </div>
            </div>
        `;
    }

    // === FUNCIONES PARA RENDERIZAR PANTALLAS DEL KIOSCO ===
    renderLoginScreen(data) {
        return `
            <div class="kiosk-screen login-screen">
                <h2>Iniciar Sesión</h2>
                <div class="form-group">
                    <label>Usuario:</label>
                    <input type="text" class="kiosk-input" value="${data?.username || ''}" readonly>
                </div>
                <div class="form-group">
                    <label>Contraseña:</label>
                    <input type="password" class="kiosk-input" value="${data?.password ? '****' : ''}" readonly>
                </div>
                <button class="kiosk-btn primary">Iniciar Sesión</button>
            </div>
        `;
    }
    
    renderZoneScreen(data) {
        return `
            <div class="kiosk-screen zone-screen">
                <h2>Seleccionar Zona</h2>
                <div class="zone-grid">
                    <div class="zone-card ${data?.selectedZone === 'MZ-V' ? 'selected' : ''}">
                        <h3>MZ-V</h3>
                        <p>Zona Verde</p>
                        <p class="price">2.10€/h</p>
                    </div>
                    <div class="zone-card ${data?.selectedZone === 'EY-V' ? 'selected' : ''}">
                        <h3>EY-V</h3>
                        <p>Zona Verde</p>
                        <p class="price">2.40€/h</p>
                    </div>
                    <div class="zone-card ${data?.selectedZone === 'EY-R' ? 'selected' : ''}">
                        <h3>EY-R</h3>
                        <p>Zona Residencial</p>
                        <p class="price">0.50€/h</p>
                    </div>
                </div>
                <button class="kiosk-btn primary">Continuar</button>
            </div>
        `;
    }
    
    renderPlateScreen(data) {
        return `
            <div class="kiosk-screen plate-screen">
                <h2>Matrícula del Vehículo</h2>
                <div class="plate-input-container">
                    <input type="text" class="kiosk-input plate-input" value="${data?.plate || ''}" placeholder="1234ABC" readonly>
                </div>
                <div class="keyboard">
                    <div class="keyboard-row">
                        <button class="key">1</button>
                        <button class="key">2</button>
                        <button class="key">3</button>
                        <button class="key">4</button>
                        <button class="key">5</button>
                    </div>
                    <div class="keyboard-row">
                        <button class="key">A</button>
                        <button class="key">B</button>
                        <button class="key">C</button>
                        <button class="key">D</button>
                        <button class="key">E</button>
                    </div>
                </div>
                <button class="kiosk-btn primary">Continuar</button>
            </div>
        `;
    }
    
    renderTimeScreen(data) {
        const selectedTime = data?.selectedTime || 60;
        return `
            <div class="kiosk-screen time-screen">
                <h2>Tiempo de Estacionamiento</h2>
                <div class="time-selector">
                    <button class="time-btn">-</button>
                    <div class="time-display">
                        <span class="time-value">${selectedTime}</span>
                        <span class="time-unit">minutos</span>
                    </div>
                    <button class="time-btn">+</button>
                </div>
                <div class="price-display">
                    <span class="total-price">${((selectedTime / 60) * 2.10).toFixed(2)}€</span>
                </div>
                <button class="kiosk-btn primary">Continuar al Pago</button>
            </div>
        `;
    }
    
    renderPaymentScreen(data) {
        return `
            <div class="kiosk-screen payment-screen">
                <h2>Método de Pago</h2>
                <div class="payment-summary">
                    <p>Matrícula: <strong>${data?.plate || '1234ABC'}</strong></p>
                    <p>Zona: <strong>${data?.zone || 'MZ-V'}</strong></p>
                    <p>Tiempo: <strong>${data?.time || '60'} min</strong></p>
                    <p>Total: <strong>${data?.total || '2.10'}€</strong></p>
                </div>
                <div class="payment-methods">
                    <button class="payment-btn ${data?.method === 'coins' ? 'selected' : ''}">
                        <i class="fas fa-coins"></i>
                        Monedas
                    </button>
                    <button class="payment-btn ${data?.method === 'card' ? 'selected' : ''}">
                        <i class="fas fa-credit-card"></i>
                        Tarjeta
                    </button>
                </div>
                <button class="kiosk-btn primary">Pagar Ahora</button>
            </div>
        `;
    }
    
    renderTicketScreen(data) {
        return `
            <div class="kiosk-screen ticket-screen">
                <h2>Ticket Generado</h2>
                <div class="ticket-preview">
                    <div class="ticket">
                        <div class="ticket-header">
                            <h3>MEYPARK</h3>
                            <p>Ticket de Estacionamiento</p>
                        </div>
                        <div class="ticket-details">
                            <p><strong>Matrícula:</strong> ${data?.plate || '1234ABC'}</p>
                            <p><strong>Zona:</strong> ${data?.zone || 'MZ-V'}</p>
                            <p><strong>Inicio:</strong> ${new Date().toLocaleString()}</p>
                            <p><strong>Fin:</strong> ${new Date(Date.now() + (data?.time || 60) * 60000).toLocaleString()}</p>
                            <p><strong>Precio:</strong> ${data?.total || '2.10'}€</p>
                        </div>
                    </div>
                </div>
                <button class="kiosk-btn primary">Imprimir Ticket</button>
                <button class="kiosk-btn secondary">Nuevo Estacionamiento</button>
            </div>
        `;
    }
    
    renderDefaultScreen(data) {
        return `
            <div class="kiosk-screen default-screen">
                <h2>MEYPARK</h2>
                <p>Sistema de Estacionamiento</p>
                <div class="status-info">
                    <p><strong>Estado:</strong> ${data?.status || 'Activo'}</p>
                    <p><strong>Usuario:</strong> ${data?.user || 'Sin usuario'}</p>
                    <p><strong>Última acción:</strong> ${data?.lastAction || 'N/A'}</p>
                </div>
                <button class="kiosk-btn primary">Comenzar</button>
            </div>
        `;
    }

    updateTechDiagnostics(diagnostics) {
        const techDiagnostics = document.getElementById('tech-diagnostics');
        techDiagnostics.innerHTML = `
            <div class="diagnostic-item">
                <strong>Red:</strong> <span class="badge ${diagnostics.network ? 'badge-success' : 'badge-danger'}">${diagnostics.network ? 'OK' : 'Error'}</span>
            </div>
            <div class="diagnostic-item">
                <strong>Impresora:</strong> <span class="badge ${diagnostics.printer ? 'badge-success' : 'badge-danger'}">${diagnostics.printer ? 'OK' : 'Error'}</span>
            </div>
            <div class="diagnostic-item">
                <strong>Pantalla:</strong> <span class="badge ${diagnostics.display ? 'badge-success' : 'badge-danger'}">${diagnostics.display ? 'OK' : 'Error'}</span>
            </div>
            <div class="diagnostic-item">
                <strong>Táctil:</strong> <span class="badge ${diagnostics.touch ? 'badge-success' : 'badge-danger'}">${diagnostics.touch ? 'OK' : 'Error'}</span>
            </div>
            <div class="diagnostic-item">
                <strong>Monedas:</strong> <span class="badge ${diagnostics.coins ? 'badge-success' : 'badge-danger'}">${diagnostics.coins ? 'OK' : 'Error'}</span>
            </div>
            <div class="diagnostic-item">
                <strong>Tarjetas:</strong> <span class="badge ${diagnostics.cards ? 'badge-success' : 'badge-danger'}">${diagnostics.cards ? 'OK' : 'Error'}</span>
            </div>
        `;
    }

    // Actualizar estadísticas desde el backend
    updateStats(stats) {
        if (stats) {
            console.log('📊 Actualizando estadísticas desde backend:', stats);
            document.getElementById('total-companies').textContent = stats.totalCompanies || 0;
            document.getElementById('total-zones').textContent = stats.totalZones || 0;
            document.getElementById('active-sessions').textContent = stats.activeSessions || 0;
            document.getElementById('today-income').textContent = (stats.todayIncome || 0).toFixed(2) + '€';
        }
    }

    // Actualizar datos completos desde el backend
    updateFullData(data) {
        if (data) {
            console.log('📊 Recibiendo datos completos del backend:', data);
            
            // Actualizar empresas
            if (data.companies) {
                this.data.companies = Object.values(data.companies);
                console.log('🏢 Empresas actualizadas:', this.data.companies.length);
            }
            
            // Actualizar zonas
            if (data.zones) {
                this.data.zones = Object.values(data.zones);
                console.log('📍 Zonas actualizadas:', this.data.zones.length);
                console.log('📍 Detalles de zonas:', this.data.zones);
            }
            
            // Actualizar sesiones activas
            if (data.activeSessions) {
                this.data.sessions = data.activeSessions;
                console.log('🚗 Sesiones actualizadas:', this.data.sessions.length);
            }
            
            // Actualizar estadísticas
            if (data.stats) {
                this.updateStats(data.stats);
                console.log('📈 Estadísticas actualizadas:', data.stats);
            }
            
            // Actualizar operadores
            if (data.operators) {
                this.data.operators = Object.values(data.operators);
                console.log('👥 Operadores actualizados:', this.data.operators.length);
            }
            
            // Recargar la sección actual si es necesario
            if (this.currentSection === 'overview') {
                this.loadOverviewData();
            } else if (this.currentSection === 'zones') {
                this.loadZonesData();
            }
        }
    }

    showSection(sectionName) {
        // Hide all sections
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.add('hidden');
        });

        // Show selected section
        const targetSection = document.getElementById(`${sectionName}-section`);
        if (targetSection) {
            targetSection.classList.remove('hidden');
            targetSection.classList.add('fade-in');
        }

        // Update navigation
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
        });
        document.querySelector(`[data-section="${sectionName}"]`).classList.add('active');

        // Update page title
        const titles = {
            overview: 'Resumen General',
            companies: 'Gestión de Empresas',
            zones: 'Zonas de Estacionamiento',
            kiosks: 'Monitoreo de Kioscos',
            sessions: 'Sesiones Activas',
            payments: 'Gestión de Pagos',
            reports: 'Reportes y Estadísticas',
            settings: 'Configuración del Sistema'
        };
        document.getElementById('page-title').textContent = titles[sectionName] || 'Dashboard';

        this.currentSection = sectionName;
        
        // Solicitar datos del backend si no los tenemos
        if (this.data.companies.length === 0 || this.data.zones.length === 0) {
            if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
                this.websocket.send(JSON.stringify({
                    type: 'get_data'
                }));
            }
        }
        
        this.loadSectionData(sectionName);
    }

    loadSectionData(sectionName) {
        // SOLO cargar datos del backend - NO datos locales
        switch (sectionName) {
            case 'overview':
                this.loadOverviewData();
                break;
            case 'companies':
                this.loadCompaniesData();
                break;
            case 'zones':
                this.loadZonesData();
                break;
            case 'sessions':
                this.loadSessionsData();
                break;
            case 'payments':
                this.loadPaymentsData();
                break;
            case 'reports':
                this.loadReportsData();
                break;
        }
    }

    loadOverviewData() {
        // SOLO usar datos del backend - NO datos locales
        // Las estadísticas se actualizan automáticamente via WebSocket
        console.log('📊 Cargando datos del resumen desde el backend...');
        
        // Mostrar indicador de carga si no hay datos
        if (this.data.companies.length === 0) {
            document.getElementById('total-companies').textContent = '...';
        }
        if (this.data.zones.length === 0) {
            document.getElementById('total-zones').textContent = '...';
        }
        if (this.data.sessions.length === 0) {
            document.getElementById('active-sessions').textContent = '...';
        }
        if (this.data.payments.length === 0) {
            document.getElementById('today-income').textContent = '...€';
        }
    }

    loadCompaniesData() {
        const tbody = document.getElementById('companies-table');
        tbody.innerHTML = '';

        // SOLO usar datos del backend - NO datos locales
        if (this.data.companies.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center">Esperando datos del backend...</td></tr>';
            // Solicitar datos del backend si no los tenemos
            if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
                this.websocket.send(JSON.stringify({
                    type: 'get_data'
                }));
            }
            return;
        }

        this.data.companies.forEach(company => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${company.id}</td>
                <td>${company.name}</td>
                <td><span class="badge" style="background-color: ${company.color}; color: white;">${company.color}</span></td>
                <td>${company.zones || 0}</td>
                <td>${company.operators || 0}</td>
                <td>${company.createdAt}</td>
                <td>
                    <button class="btn btn-sm btn-primary" onclick="dashboard.editCompany('${company.id}')">
                        <i class="fas fa-edit"></i> Editar
                    </button>
                    <button class="btn btn-sm btn-warning" onclick="console.log('🔐 Botón login clickeado para:', '${company.id}'); dashboard.showChangeLoginModal('${company.id}')">
                        <i class="fas fa-key"></i> Login
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="dashboard.deleteCompany('${company.id}')">
                        <i class="fas fa-trash"></i> Eliminar
                    </button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    loadZonesData() {
        const tbody = document.getElementById('zones-table');
        tbody.innerHTML = '';

        console.log('📍 Cargando datos de zonas:', this.data.zones);

        // SOLO usar datos del backend - NO datos locales
        if (this.data.zones.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center">Esperando datos del backend...</td></tr>';
            // Solicitar datos del backend si no los tenemos
            if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
                this.websocket.send(JSON.stringify({
                    type: 'get_data'
                }));
            }
            return;
        }

        this.data.zones.forEach(zone => {
            console.log('📍 Procesando zona:', zone);
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${zone.id}</td>
                <td>${zone.name}</td>
                <td>${this.getCompanyName(zone.companyId)}</td>
                <td>${(zone.pricePerHour || zone.hourlyRate || 0).toFixed(2)}€</td>
                <td>${zone.maxHours || 0}h</td>
                <td>
                    <span class="status-badge ${zone.isActive ? 'active' : 'inactive'}">
                        ${zone.isActive ? 'Activa' : 'Inactiva'}
                    </span>
                </td>
                <td>
                    <button class="btn btn-sm btn-primary" onclick="dashboard.editZone('${zone.id}')">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="dashboard.deleteZone('${zone.id}')">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    loadSessionsData() {
        const tbody = document.getElementById('sessions-table');
        tbody.innerHTML = '';

        // SOLO usar datos del backend - NO datos locales
        if (this.data.sessions.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center">Esperando datos del backend...</td></tr>';
            // Solicitar datos del backend si no los tenemos
            if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
                this.websocket.send(JSON.stringify({
                    type: 'get_data'
                }));
            }
            return;
        }

        this.data.sessions.forEach(session => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${session.plate}</td>
                <td>${session.zone}</td>
                <td>${session.start}</td>
                <td>${session.end}</td>
                <td>${session.price.toFixed(2)}€</td>
                <td><span class="badge badge-success">${session.status}</span></td>
                <td>
                    <button class="btn btn-warning" onclick="dashboard.extendSession('${session.plate}')">
                        <i class="fas fa-clock"></i> Extender
                    </button>
                    <button class="btn btn-danger" onclick="dashboard.endSession('${session.plate}')">
                        <i class="fas fa-stop"></i> Finalizar
                    </button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    loadPaymentsData() {
        const tbody = document.getElementById('payments-table');
        tbody.innerHTML = '';

        // SOLO usar datos del backend - NO datos locales
        if (this.data.payments.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center">Esperando datos del backend...</td></tr>';
            // Solicitar datos del backend si no los tenemos
            if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
                this.websocket.send(JSON.stringify({
                    type: 'get_data'
                }));
            }
            return;
        }

        this.data.payments.forEach(payment => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${payment.id}</td>
                <td>${payment.plate}</td>
                <td>${payment.zone}</td>
                <td>${payment.method}</td>
                <td>${payment.amount.toFixed(2)}€</td>
                <td>${payment.date}</td>
                <td><span class="badge badge-success">${payment.status}</span></td>
            `;
            tbody.appendChild(row);
        });

        // Update today's income
        const todayIncome = this.data.payments.reduce((sum, payment) => sum + payment.amount, 0);
        document.getElementById('today-income-detail').textContent = todayIncome.toFixed(2) + '€';
    }

    loadReportsData() {
        // SOLO usar datos del backend - NO datos locales
        console.log('📊 Cargando reportes desde el backend...');
        this.loadDailyIncomeChart();
        this.loadZonesUsageChart();
    }

    loadDailyIncomeChart() {
        const ctx = document.getElementById('daily-income-chart').getContext('2d');
        // SOLO usar datos del backend - NO datos locales
        ctx.fillStyle = '#E62144';
        ctx.font = '16px Arial';
        ctx.fillText('Gráfico de Ingresos Diarios (Datos del Backend)', 50, 150);
    }

    loadZonesUsageChart() {
        const ctx = document.getElementById('zones-usage-chart').getContext('2d');
        // SOLO usar datos del backend - NO datos locales
        ctx.fillStyle = '#2196F3';
        ctx.font = '16px Arial';
        ctx.fillText('Gráfico de Uso de Zonas (Datos del Backend)', 50, 150);
    }

    showAddCompanyModal() {
        document.getElementById('add-company-modal').classList.add('show');
    }

    showAddZoneModal() {
        // SOLO usar datos del backend - NO datos locales
        const companySelect = document.getElementById('zone-company');
        companySelect.innerHTML = '<option value="">Seleccionar empresa...</option>';
        
        if (this.data.companies.length === 0) {
            companySelect.innerHTML = '<option value="">Esperando datos del backend...</option>';
        } else {
            this.data.companies.forEach(company => {
                const option = document.createElement('option');
                option.value = company.id;
                option.textContent = company.name;
                companySelect.appendChild(option);
            });
        }
        
        document.getElementById('add-zone-modal').classList.add('show');
    }

    closeModal(modalId) {
        document.getElementById(modalId).classList.remove('show');
    }

    addCompany() {
        const name = document.getElementById('company-name').value;
        const color = document.getElementById('company-color').value;
        const bgColor = document.getElementById('company-bg-color').value;

        // SOLO usar datos del backend - NO datos locales
        const newCompany = {
            id: 'company-' + Date.now(),
            name: name,
            color: color,
            bgColor: bgColor,
            zones: 0,
            operators: 0,
            createdAt: new Date().toISOString().split('T')[0]
        };

        this.data.companies.push(newCompany);
        
        // Enviar al kiosco Flutter
        this.sendToKiosco({
            type: 'update_company',
            data: newCompany
        });
        
        this.showToast('Empresa creada exitosamente', 'success');
        this.closeModal('add-company-modal');
        this.resetCompanyForm();
        this.loadCompaniesData();
    }

    addZone() {
        const companyId = document.getElementById('zone-company').value;
        const zoneId = document.getElementById('zone-id').value;
        const name = document.getElementById('zone-name').value;
        const price = parseFloat(document.getElementById('zone-price').value);
        const maxHours = parseInt(document.getElementById('zone-max-hours').value);
        const color = document.getElementById('zone-color').value;

        // Validaciones
        if (!companyId) {
            this.showToast('Selecciona una empresa', 'error');
            return;
        }
        
        if (!zoneId || !name || !price || !maxHours) {
            this.showToast('Completa todos los campos', 'error');
            return;
        }

        // SOLO usar datos del backend - NO datos locales
        if (this.data.companies.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }

        const company = this.data.companies.find(c => c.id === companyId);
        if (!company) {
            this.showToast('Empresa no encontrada', 'error');
            return;
        }

        const newZone = {
            id: zoneId,
            companyId: companyId,
            name: name,
            company: company.name,
            pricePerHour: price,
            maxHours: maxHours,
            color: color,
            createdAt: new Date().toISOString()
        };

        this.data.zones.push(newZone);
        company.zones++;
        
        // Enviar al kiosco Flutter
        this.sendToKiosco({
            type: 'update_zone',
            data: newZone
        });
        
        this.showToast('Zona creada exitosamente', 'success');
        this.closeModal('add-zone-modal');
        this.loadZonesData();
        this.resetZoneForm();
    }

    editCompany(companyId) {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.companies.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }
        
        const company = this.data.companies.find(c => c.id === companyId);
        if (!company) {
            this.showToast('Empresa no encontrada', 'error');
            return;
        }

        // Llenar formulario con datos existentes
        document.getElementById('company-name').value = company.name;
        document.getElementById('company-color').value = company.color || '#E62144';
        document.getElementById('company-bg-color').value = company.bgColor || '#FFFFFF';
        
        // Cambiar título del modal
        document.querySelector('#add-company-modal .modal-title').textContent = 'Editar Empresa';
        
        // Cambiar botón de envío
        const submitBtn = document.querySelector('#add-company-form button[type="submit"]');
        submitBtn.textContent = 'Actualizar Empresa';
        submitBtn.onclick = () => this.updateCompany(companyId);
        
        this.showAddCompanyModal();
    }

    updateCompany(companyId) {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.companies.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }
        
        const name = document.getElementById('company-name').value;
        const color = document.getElementById('company-color').value;
        const bgColor = document.getElementById('company-bg-color').value;

        const companyIndex = this.data.companies.findIndex(c => c.id === companyId);
        if (companyIndex >= 0) {
            this.data.companies[companyIndex] = {
                ...this.data.companies[companyIndex],
                name: name,
                color: color,
                bgColor: bgColor
            };
            
            this.showToast('Empresa actualizada exitosamente', 'success');
            this.closeModal('add-company-modal');
            this.loadCompaniesData();
            this.resetCompanyForm();
        }
    }

    deleteCompany(companyId) {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.companies.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }
        
        if (confirm('¿Estás seguro de que quieres eliminar esta empresa?')) {
            // Verificar si hay zonas asociadas
            const hasZones = this.data.zones.some(z => z.companyId === companyId);
            if (hasZones) {
                this.showToast('No se puede eliminar: la empresa tiene zonas asociadas', 'error');
                return;
            }
            
            this.data.companies = this.data.companies.filter(c => c.id !== companyId);
            this.showToast('Empresa eliminada', 'success');
            this.loadCompaniesData();
        }
    }

    editZone(zoneId) {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.zones.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }
        
        const zone = this.data.zones.find(z => z.id === zoneId);
        if (!zone) {
            this.showToast('Zona no encontrada', 'error');
            return;
        }

        // Llenar formulario con datos existentes
        document.getElementById('zone-company').value = this.data.companies.find(c => c.name === zone.company)?.id || '';
        document.getElementById('zone-id').value = zone.id;
        document.getElementById('zone-name').value = zone.name;
        document.getElementById('zone-price').value = zone.price;
        document.getElementById('zone-max-hours').value = zone.maxHours;
        document.getElementById('zone-color').value = zone.color;
        
        // Cambiar título del modal
        document.querySelector('#add-zone-modal .modal-title').textContent = 'Editar Zona';
        
        // Cambiar botón de envío
        const submitBtn = document.querySelector('#add-zone-form button[type="submit"]');
        submitBtn.textContent = 'Actualizar Zona';
        submitBtn.onclick = () => this.updateZone(zoneId);
        
        this.showAddZoneModal();
    }

    updateZone(zoneId) {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.zones.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }
        
        const companyId = document.getElementById('zone-company').value;
        const zoneIdNew = document.getElementById('zone-id').value;
        const name = document.getElementById('zone-name').value;
        const price = parseFloat(document.getElementById('zone-price').value);
        const maxHours = parseInt(document.getElementById('zone-max-hours').value);
        const color = document.getElementById('zone-color').value;

        const company = this.data.companies.find(c => c.id === companyId);
        if (!company) {
            this.showToast('Empresa no encontrada', 'error');
            return;
        }

        const zoneIndex = this.data.zones.findIndex(z => z.id === zoneId);
        if (zoneIndex >= 0) {
            this.data.zones[zoneIndex] = {
                ...this.data.zones[zoneIndex],
                id: zoneIdNew,
                name: name,
                company: company.name,
                companyId: companyId,
                price: price,
                maxHours: maxHours,
                color: color
            };
            
            this.showToast('Zona actualizada exitosamente', 'success');
            this.closeModal('add-zone-modal');
            this.loadZonesData();
            this.resetZoneForm();
        }
    }

    deleteZone(zoneId) {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.zones.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }
        
        if (confirm('¿Estás seguro de que quieres eliminar esta zona?')) {
            // Verificar si hay sesiones activas en esta zona
            const hasActiveSessions = this.data.sessions.some(s => s.zone === zoneId);
            if (hasActiveSessions) {
                this.showToast('No se puede eliminar: la zona tiene sesiones activas', 'error');
                return;
            }
            
            this.data.zones = this.data.zones.filter(z => z.id !== zoneId);
            this.showToast('Zona eliminada', 'success');
            this.loadZonesData();
        }
    }

    resetCompanyForm() {
        document.getElementById('company-name').value = '';
        document.getElementById('company-color').value = '#E62144';
        document.getElementById('company-bg-color').value = '#FFFFFF';
        document.querySelector('#add-company-modal .modal-title').textContent = 'Nueva Empresa';
        const submitBtn = document.querySelector('#add-company-form button[type="submit"]');
        submitBtn.textContent = 'Crear Empresa';
        submitBtn.onclick = () => this.addCompany();
    }

    resetZoneForm() {
        document.getElementById('zone-company').value = '';
        document.getElementById('zone-id').value = '';
        document.getElementById('zone-name').value = '';
        document.getElementById('zone-price').value = '';
        document.getElementById('zone-max-hours').value = '';
        document.getElementById('zone-color').value = '#2196F3';
        document.querySelector('#add-zone-modal .modal-title').textContent = 'Nueva Zona';
        const submitBtn = document.querySelector('#add-zone-form button[type="submit"]');
        submitBtn.textContent = 'Crear Zona';
        submitBtn.onclick = () => this.addZone();
    }

    extendSession(plate) {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.sessions.length === 0) {
            this.showToast('No hay sesiones para extender', 'error');
            return;
        }
        
        const session = this.data.sessions.find(s => s.plate === plate);
        if (!session) {
            this.showToast('Sesión no encontrada', 'error');
            return;
        }

        const newTime = prompt(`Tiempo actual: ${session.end}\nNuevo tiempo (formato HH:MM):`, session.end);
        if (newTime && newTime !== session.end) {
            // Calcular nuevo precio basado en el tiempo extendido
            const zone = this.data.zones.find(z => z.id === session.zone);
            if (zone) {
                const currentHours = this.calculateHours(session.start, session.end);
                const newHours = this.calculateHours(session.start, newTime);
                const additionalHours = newHours - currentHours;
                const additionalPrice = additionalHours * zone.price;
                
                session.end = newTime;
                session.price += additionalPrice;
                
                this.showToast(`Sesión extendida. Precio adicional: ${additionalPrice.toFixed(2)}€`, 'success');
                this.loadSessionsData();
            }
        }
    }

    endSession(plate) {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.sessions.length === 0) {
            this.showToast('No hay sesiones para finalizar', 'error');
            return;
        }
        
        if (confirm('¿Estás seguro de que quieres finalizar esta sesión?')) {
            const session = this.data.sessions.find(s => s.plate === plate);
            if (session) {
                // Agregar a historial de pagos
                this.data.payments.push({
                    id: 'P' + Date.now(),
                    plate: session.plate,
                    zone: session.zone,
                    method: 'Manual',
                    amount: session.price,
                    date: new Date().toISOString().replace('T', ' ').substring(0, 19),
                    status: 'completed'
                });
                
                this.data.stats.todayIncome += session.price;
            }
            
            this.data.sessions = this.data.sessions.filter(s => s.plate !== plate);
            this.data.stats.activeSessions = this.data.sessions.length;
            this.showToast('Sesión finalizada', 'success');
            this.loadSessionsData();
            this.loadPaymentsData();
        }
    }

    calculateHours(startTime, endTime) {
        // SOLO usar datos del backend - NO datos locales
        const start = new Date(`2000-01-01 ${startTime}`);
        const end = new Date(`2000-01-01 ${endTime}`);
        return (end - start) / (1000 * 60 * 60); // Convertir a horas
    }

    exportSessions() {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.sessions.length === 0) {
            this.showToast('No hay sesiones para exportar', 'warning');
            return;
        }

        // Crear CSV
        let csv = 'Matrícula,Zona,Inicio,Fin,Precio,Estado\n';
        this.data.sessions.forEach(session => {
            csv += `${session.plate},${session.zone},${session.start},${session.end},${session.price.toFixed(2)},${session.status}\n`;
        });

        // Descargar archivo
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `sesiones_${new Date().toISOString().split('T')[0]}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        this.showToast('Sesiones exportadas exitosamente', 'success');
    }

    refreshData() {
        // Solicitar datos frescos del backend
        if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
            this.websocket.send(JSON.stringify({
                type: 'get_data'
            }));
            this.showToast('Solicitando datos del backend...', 'info');
        } else {
            this.showToast('No hay conexión con el backend', 'error');
        }
    }

    startDataRefresh() {
        setInterval(() => {
            this.updateTime();
            // NO recargar datos locales - solo actualizar tiempo
            // Los datos se actualizan automáticamente via WebSocket
        }, this.updateInterval);
    }

    updateTime() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('es-ES', { 
            hour: '2-digit', 
            minute: '2-digit' 
        });
        document.getElementById('update-time').textContent = timeString;
        document.getElementById('kiosk-time').textContent = timeString;
    }

    showToast(message, type = 'success') {
        const toast = document.getElementById('toast');
        toast.textContent = message;
        toast.className = `toast ${type}`;
        toast.classList.add('show');

        setTimeout(() => {
            toast.classList.remove('show');
        }, 3000);
    }

    loadSettings() {
        const settings = JSON.parse(localStorage.getItem('meypark-dashboard-settings') || '{}');
        this.websocketUrl = settings.websocketUrl || 'ws://localhost:8080';
        this.updateInterval = settings.updateInterval || 5000;
        
        document.getElementById('websocket-url').value = this.websocketUrl;
        document.getElementById('update-interval').value = this.updateInterval;
        
        // Cargar preferencias de accesibilidad
        this.loadAccessibilitySettings();
    }

    loadAccessibilitySettings() {
        // Cargar modo oscuro
        const darkMode = localStorage.getItem('meypark-dashboard-dark-mode') === 'true';
        document.getElementById('dark-mode').checked = darkMode;
        document.body.classList.toggle('dark-mode', darkMode);
        
        // Cargar alto contraste
        const highContrast = localStorage.getItem('meypark-dashboard-high-contrast') === 'true';
        document.getElementById('high-contrast').checked = highContrast;
        document.body.classList.toggle('high-contrast', highContrast);
        
        // Cargar tamaño de fuente
        const fontSize = localStorage.getItem('meypark-dashboard-font-size') || 'normal';
        document.getElementById('font-size').value = fontSize;
        document.body.className = document.body.className.replace(/font-\w+/g, '');
        document.body.classList.add(`font-${fontSize}`);
        
        // Cargar reducir animaciones
        const reduceAnimations = localStorage.getItem('meypark-dashboard-reduce-animations') === 'true';
        document.getElementById('reduce-animations').checked = reduceAnimations;
        document.body.classList.toggle('reduce-animations', reduceAnimations);
        
        // Cargar idioma
        const language = localStorage.getItem('meypark-dashboard-language') || 'es-ES';
        document.getElementById('language-select').value = language;
        this.changeLanguage(language);
    }

    saveSettings() {
        const settings = {
            websocketUrl: document.getElementById('websocket-url').value,
            updateInterval: parseInt(document.getElementById('update-interval').value)
        };
        
        localStorage.setItem('meypark-dashboard-settings', JSON.stringify(settings));
        this.websocketUrl = settings.websocketUrl;
        this.updateInterval = settings.updateInterval;
        
        this.showToast('Configuración guardada', 'success');
        this.connectWebSocket();
    }

    toggleDarkMode() {
        const isDarkMode = document.getElementById('dark-mode').checked;
        document.body.classList.toggle('dark-mode', isDarkMode);
        
        // Guardar preferencia
        localStorage.setItem('meypark-dashboard-dark-mode', isDarkMode);
        
        // Enviar al kiosco Flutter
        this.sendToKiosco({
            type: 'update_ui',
            data: { darkMode: isDarkMode }
        });
        
        this.showToast('Modo oscuro actualizado', 'success');
    }

    toggleHighContrast() {
        const isHighContrast = document.getElementById('high-contrast').checked;
        document.body.classList.toggle('high-contrast', isHighContrast);
        
        // Guardar preferencia
        localStorage.setItem('meypark-dashboard-high-contrast', isHighContrast);
        
        // Enviar al kiosco Flutter
        this.sendToKiosco({
            type: 'update_ui',
            data: { highContrast: isHighContrast }
        });
        
        this.showToast('Alto contraste actualizado', 'success');
    }

    changeFontSize() {
        const fontSize = document.getElementById('font-size').value;
        document.body.className = document.body.className.replace(/font-\w+/g, '');
        document.body.classList.add(`font-${fontSize}`);
        
        // Guardar preferencia
        localStorage.setItem('meypark-dashboard-font-size', fontSize);
        
        // Enviar al kiosco Flutter
        this.sendToKiosco({
            type: 'update_ui',
            data: { fontSize: fontSize }
        });
        
        this.showToast('Tamaño de fuente actualizado', 'success');
    }

    toggleReduceAnimations() {
        const reduceAnimations = document.getElementById('reduce-animations').checked;
        document.body.classList.toggle('reduce-animations', reduceAnimations);
        
        // Guardar preferencia
        localStorage.setItem('meypark-dashboard-reduce-animations', reduceAnimations);
        
        // Enviar al kiosco Flutter
        this.sendToKiosco({
            type: 'update_ui',
            data: { reduceAnimations: reduceAnimations }
        });
        
        this.showToast('Animaciones actualizadas', 'success');
    }

    // Enviar mensaje al kiosco Flutter
    sendToKiosco(message) {
        if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
            this.websocket.send(JSON.stringify(message));
            console.log('Mensaje enviado al kiosco:', message);
        } else {
            console.warn('WebSocket no conectado, no se puede enviar mensaje al kiosco');
        }
    }

    // === FUNCIONES PARA MODO TÉCNICO ===
    refreshTechStatus() {
        this.sendToKiosco({
            type: 'get_tech_status'
        });
        this.showToast('Estado técnico actualizado', 'success');
    }

    runTechTest(testType) {
        this.sendToKiosco({
            type: 'run_tech_test',
            testType: testType
        });
        this.showToast(`Ejecutando test de ${testType}...`, 'info');
    }

    resetDayCounters() {
        if (confirm('¿Estás seguro de que quieres reiniciar los contadores del día?')) {
            this.sendToKiosco({
                type: 'reset_day_counters'
            });
            this.showToast('Contadores del día reiniciados', 'success');
        }
    }

    reloadConfig() {
        this.sendToKiosco({
            type: 'reload_config'
        });
        this.showToast('Configuración recargada', 'success');
    }

    rebootKioskApp() {
        if (confirm('¿Estás seguro de que quieres reiniciar la aplicación del kiosco?')) {
            this.sendToKiosco({
                type: 'reboot_app'
            });
            this.showToast('Reiniciando aplicación del kiosco...', 'warning');
        }
    }

    restartKiosk() {
        if (confirm('¿Estás seguro de que quieres reiniciar el kiosco completo?')) {
            this.sendToKiosco({
                type: 'restart_kiosk'
            });
            this.showToast('Reiniciando kiosco...', 'warning');
        }
    }

    closeKiosk() {
        if (confirm('¿Estás seguro de que quieres cerrar el kiosco?')) {
            this.sendToKiosco({
                type: 'close_kiosk'
            });
            this.showToast('Cerrando kiosco...', 'warning');
        }
    }

    // === FUNCIONES PARA OPERADORES ===
    showAddOperatorModal() {
        // SOLO usar datos del backend - NO datos locales
        this.populateCompanySelect('operator-company');
        this.showModal('add-operator-modal');
    }

    // === FUNCIONES PARA SESIONES ===
    showExtendSessionModal() {
        this.showModal('extend-session-modal');
    }

    searchSessions() {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.sessions.length === 0) {
            this.showToast('No hay sesiones para buscar', 'warning');
            return;
        }
        
        const searchTerm = document.getElementById('session-search').value.toLowerCase();
        const rows = document.querySelectorAll('#sessions-table tr');
        
        rows.forEach(row => {
            const plate = row.cells[0]?.textContent.toLowerCase() || '';
            if (plate.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    clearSessionSearch() {
        // SOLO usar datos del backend - NO datos locales
        document.getElementById('session-search').value = '';
        this.searchSessions();
    }

    // === FUNCIONES PARA PAGOS ===
    showPaymentModal() {
        // SOLO usar datos del backend - NO datos locales
        this.populateZoneSelect('payment-modal-zone');
        this.showModal('payment-modal');
    }

    simulatePayment() {
        const plate = document.getElementById('payment-plate').value;
        const amount = parseFloat(document.getElementById('payment-amount').value);
        const method = document.getElementById('payment-method').value;

        if (!plate || !amount) {
            this.showToast('Por favor completa todos los campos', 'error');
            return;
        }

        // SOLO usar datos del backend - NO datos locales
        if (this.data.zones.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }

        this.sendToKiosco({
            type: 'simulate_payment',
            data: { plate, amount, method }
        });
        this.showToast('Pago simulado exitosamente', 'success');
    }

    // === FUNCIONES PARA TICKETS ===
    showGenerateTicketModal() {
        // SOLO usar datos del backend - NO datos locales
        this.populateZoneSelect('ticket-zone');
        this.showModal('generate-ticket-modal');
    }

    generateTicket() {
        const plate = document.getElementById('ticket-plate').value;
        const zone = document.getElementById('ticket-zone').value;
        const duration = parseInt(document.getElementById('ticket-duration').value);
        const type = document.getElementById('ticket-type').value;

        if (!plate || !zone || !duration) {
            this.showToast('Por favor completa todos los campos', 'error');
            return;
        }

        // SOLO usar datos del backend - NO datos locales
        if (this.data.zones.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }

        // Actualizar vista previa
        this.updateTicketPreview(plate, zone, duration, type);
        
        this.sendToKiosco({
            type: 'generate_ticket',
            data: { plate, zone, duration, type }
        });
        this.showToast('Ticket generado exitosamente', 'success');
    }

    updateTicketPreview(plate, zone, duration, type) {
        const now = new Date();
        const endTime = new Date(now.getTime() + duration * 60000);
        
        document.getElementById('preview-plate').textContent = plate;
        document.getElementById('preview-zone').textContent = zone;
        document.getElementById('preview-start').textContent = now.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' });
        document.getElementById('preview-end').textContent = endTime.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' });
        
        // SOLO usar datos del backend - NO datos locales
        // Buscar precio real de la zona en el backend
        const zoneData = this.data.zones.find(z => z.id === zone);
        if (zoneData && zoneData.pricePerHour) {
            const price = (duration / 60) * zoneData.pricePerHour;
            document.getElementById('preview-amount').textContent = price.toFixed(2) + '€';
        } else {
            // Fallback si no hay datos del backend
            const price = duration * 0.02; // 0.02€ por minuto
            document.getElementById('preview-amount').textContent = price.toFixed(2) + '€';
        }
    }

    printAllTickets() {
        // SOLO usar datos del backend - NO datos locales
        if (this.data.sessions.length === 0) {
            this.showToast('No hay sesiones para imprimir', 'error');
            return;
        }
        
        this.sendToKiosco({
            type: 'print_all_tickets'
        });
        this.showToast('Imprimiendo todos los tickets...', 'info');
    }

    // === FUNCIÓN PARA IDIOMA ===
    changeLanguage(language) {
        // Guardar preferencia
        localStorage.setItem('meypark-dashboard-language', language);
        
        // Enviar al kiosco Flutter
        this.sendToKiosco({
            type: 'update_ui',
            data: { language: language }
        });
        
        this.showToast('Idioma cambiado', 'success');
    }

    // === FUNCIONES AUXILIARES ===
    populateCompanySelect(selectId) {
        const select = document.getElementById(selectId);
        select.innerHTML = '<option value="">Seleccionar empresa...</option>';
        
        if (this.data.companies.length === 0) {
            select.innerHTML = '<option value="">Esperando datos del backend...</option>';
        } else {
            this.data.companies.forEach(company => {
                const option = document.createElement('option');
                option.value = company.id;
                option.textContent = company.name;
                select.appendChild(option);
            });
        }
    }

    populateZoneSelect(selectId) {
        const select = document.getElementById(selectId);
        select.innerHTML = '<option value="">Seleccionar zona...</option>';
        
        if (this.data.zones.length === 0) {
            select.innerHTML = '<option value="">Esperando datos del backend...</option>';
        } else {
            this.data.zones.forEach(zone => {
                const option = document.createElement('option');
                option.value = zone.id;
                option.textContent = `${zone.name} (${zone.pricePerHour}€/h)`;
                select.appendChild(option);
            });
        }
    }

    showModal(modalId) {
        console.log('📱 Mostrando modal:', modalId);
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'block';
            modal.classList.add('show');
            console.log('✅ Modal mostrado correctamente');
        } else {
            console.error('❌ Modal no encontrado:', modalId);
        }
    }

    closeModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'none';
            modal.classList.remove('show');
        }
    }

    // === FUNCIONES PARA EMPRESAS ===
    editCompany(companyId) {
        const company = this.data.companies.find(c => c.id === companyId);
        if (!company) {
            this.showToast('Empresa no encontrada', 'error');
            return;
        }

        // Llenar formulario con datos existentes
        document.getElementById('company-name').value = company.name;
        document.getElementById('company-color').value = company.color;
        document.getElementById('company-bg-color').value = company.bgColor || '#FFFFFF';
        
        // Cambiar título del modal
        document.querySelector('#add-company-modal .modal-title').textContent = 'Editar Empresa';
        
        // Cambiar botón de envío
        const submitBtn = document.querySelector('#add-company-form button[type="submit"]');
        submitBtn.textContent = 'Actualizar Empresa';
        submitBtn.onclick = () => this.updateCompany(companyId);
        
        this.showModal('add-company-modal');
    }

    updateCompany(companyId) {
        const name = document.getElementById('company-name').value;
        const color = document.getElementById('company-color').value;
        const bgColor = document.getElementById('company-bg-color').value;

        const companyIndex = this.data.companies.findIndex(c => c.id === companyId);
        if (companyIndex >= 0) {
            this.data.companies[companyIndex] = {
                ...this.data.companies[companyIndex],
                name: name,
                color: color,
                bgColor: bgColor
            };
            
            this.showToast('Empresa actualizada exitosamente', 'success');
            this.closeModal('add-company-modal');
            this.loadCompaniesData();
            this.resetCompanyForm();
            
            // Enviar al kiosco Flutter
            this.sendToKiosco({
                type: 'update_company',
                data: this.data.companies[companyIndex]
            });
        }
    }

    deleteCompany(companyId) {
        if (confirm('¿Estás seguro de que quieres eliminar esta empresa?')) {
            // Verificar si hay zonas asociadas
            const hasZones = this.data.zones.some(z => z.companyId === companyId);
            if (hasZones) {
                this.showToast('No se puede eliminar: la empresa tiene zonas asociadas', 'error');
                return;
            }
            
            this.data.companies = this.data.companies.filter(c => c.id !== companyId);
            this.showToast('Empresa eliminada', 'success');
            this.loadCompaniesData();
            
            // Enviar al kiosco Flutter
            this.sendToKiosco({
                type: 'delete_company',
                data: { companyId: companyId }
            });
        }
    }

    resetCompanyForm() {
        // SOLO usar datos del backend - NO datos locales
        document.getElementById('company-name').value = '';
        document.getElementById('company-color').value = '#E62144';
        document.getElementById('company-bg-color').value = '#FFFFFF';
        
        // Restaurar título y botón originales
        document.querySelector('#add-company-modal .modal-title').textContent = 'Nueva Empresa';
        const submitBtn = document.querySelector('#add-company-form button[type="submit"]');
        submitBtn.textContent = 'Crear Empresa';
        submitBtn.onclick = () => this.addCompany();
    }

    // === FUNCIONES PARA ZONAS ===
    editZone(zoneId) {
        const zone = this.data.zones.find(z => z.id === zoneId);
        if (!zone) {
            this.showToast('Zona no encontrada', 'error');
            return;
        }

        // Llenar formulario con datos existentes
        document.getElementById('zone-company').value = zone.companyId;
        document.getElementById('zone-id').value = zone.id;
        document.getElementById('zone-name').value = zone.name;
        document.getElementById('zone-price').value = zone.pricePerHour;
        document.getElementById('zone-max-hours').value = zone.maxHours;
        document.getElementById('zone-color').value = zone.color;
        
        // Cambiar título del modal
        document.querySelector('#add-zone-modal .modal-title').textContent = 'Editar Zona';
        
        // Cambiar botón de envío
        const submitBtn = document.querySelector('#add-zone-form button[type="submit"]');
        submitBtn.textContent = 'Actualizar Zona';
        submitBtn.onclick = () => this.updateZone(zoneId);
        
        this.showModal('add-zone-modal');
    }

    updateZone(zoneId) {
        const companyId = document.getElementById('zone-company').value;
        const id = document.getElementById('zone-id').value;
        const name = document.getElementById('zone-name').value;
        const price = parseFloat(document.getElementById('zone-price').value);
        const maxHours = parseInt(document.getElementById('zone-max-hours').value);
        const color = document.getElementById('zone-color').value;

        const zoneIndex = this.data.zones.findIndex(z => z.id === zoneId);
        if (zoneIndex >= 0) {
            this.data.zones[zoneIndex] = {
                ...this.data.zones[zoneIndex],
                companyId: companyId,
                id: id,
                name: name,
                pricePerHour: price,
                maxHours: maxHours,
                color: color
            };
            
            this.showToast('Zona actualizada exitosamente', 'success');
            this.closeModal('add-zone-modal');
            this.loadZonesData();
            this.resetZoneForm();
            
            // Enviar al kiosco Flutter
            this.sendToKiosco({
                type: 'update_zone',
                data: this.data.zones[zoneIndex]
            });
        }
    }

    deleteZone(zoneId) {
        if (confirm('¿Estás seguro de que quieres eliminar esta zona?')) {
            this.data.zones = this.data.zones.filter(z => z.id !== zoneId);
            this.showToast('Zona eliminada', 'success');
            this.loadZonesData();
            
            // Enviar al kiosco Flutter
            this.sendToKiosco({
                type: 'delete_zone',
                data: { zoneId: zoneId }
            });
        }
    }

    resetZoneForm() {
        // SOLO usar datos del backend - NO datos locales
        document.getElementById('zone-company').value = '';
        document.getElementById('zone-id').value = '';
        document.getElementById('zone-name').value = '';
        document.getElementById('zone-price').value = '';
        document.getElementById('zone-max-hours').value = '';
        document.getElementById('zone-color').value = '#2196F3';
        
        // Restaurar título y botón originales
        document.querySelector('#add-zone-modal .modal-title').textContent = 'Nueva Zona';
        const submitBtn = document.querySelector('#add-zone-form button[type="submit"]');
        submitBtn.textContent = 'Crear Zona';
        submitBtn.onclick = () => this.addZone();
    }

    // === INICIALIZACIÓN DE LA SIMULACIÓN ===
    initKioskSimulation() {
        // SOLO usar datos del backend - NO datos locales
        // Mostrar pantalla de login por defecto
        this.updateKioskScreen({
            screen: 'login',
            connected: false,
            user: 'Sin usuario',
            lastAction: 'Esperando conexión...'
        });
    }

    // === FUNCIONES PARA CAMBIO DE LOGIN ===
    showChangeLoginModal(companyId = null) {
        console.log('🔐 Abriendo modal de cambio de login para empresa:', companyId);
        
        // SOLO usar datos del backend - NO datos locales
        if (companyId) {
            const company = this.data.companies.find(c => c.id === companyId);
            if (company) {
                document.getElementById('login-company').value = companyId;
                this.loadCurrentOperator(companyId);
            }
        } else {
            // Llenar select de empresas
            const companySelect = document.getElementById('login-company');
            companySelect.innerHTML = '<option value="">Seleccionar empresa...</option>';
            
            if (this.data.companies.length === 0) {
                companySelect.innerHTML = '<option value="">Esperando datos del backend...</option>';
            } else {
                this.data.companies.forEach(company => {
                    const option = document.createElement('option');
                    option.value = company.id;
                    option.textContent = company.name;
                    companySelect.appendChild(option);
                });
            }
        }

        // Limpiar formulario
        document.getElementById('current-username').value = '';
        document.getElementById('new-username').value = '';
        document.getElementById('new-password').value = '';
        document.getElementById('confirm-password').value = '';

        // Event listener para cargar usuario actual cuando se selecciona empresa
        companySelect.addEventListener('change', () => {
            this.loadCurrentOperator(companySelect.value);
        });

        // Event listener para el formulario
        document.getElementById('change-login-form').onsubmit = (e) => {
            e.preventDefault();
            this.updateLogin();
        };

        this.showModal('change-login-modal');
    }

    loadCurrentOperator(companyId) {
        if (!companyId) return;

        // SOLO usar datos del backend - NO datos locales
        if (this.data.operators.length === 0) {
            document.getElementById('current-username').value = 'Esperando datos del backend...';
            return;
        }

        // Buscar operador actual de la empresa
        const operator = this.data.operators.find(op => op.companyId === companyId);
        if (operator) {
            document.getElementById('current-username').value = operator.username;
        } else {
            document.getElementById('current-username').value = 'No encontrado';
        }
    }

    updateLogin() {
        const companyId = document.getElementById('login-company').value;
        const newUsername = document.getElementById('new-username').value;
        const newPassword = document.getElementById('new-password').value;
        const confirmPassword = document.getElementById('confirm-password').value;

        // Validaciones
        if (!companyId) {
            this.showToast('Selecciona una empresa', 'error');
            return;
        }

        if (!newUsername || !newPassword) {
            this.showToast('Completa todos los campos', 'error');
            return;
        }

        if (newPassword !== confirmPassword) {
            this.showToast('Las contraseñas no coinciden', 'error');
            return;
        }

        if (newPassword.length < 6) {
            this.showToast('La contraseña debe tener al menos 6 caracteres', 'error');
            return;
        }

        // SOLO usar datos del backend - NO datos locales
        if (this.data.operators.length === 0) {
            this.showToast('Esperando datos del backend...', 'error');
            return;
        }

        // Actualizar operador
        const operatorIndex = this.data.operators.findIndex(op => op.companyId === companyId);
        if (operatorIndex >= 0) {
            this.data.operators[operatorIndex] = {
                ...this.data.operators[operatorIndex],
                username: newUsername,
                password: newPassword
            };
        } else {
            // Crear nuevo operador si no existe
            this.data.operators.push({
                id: 'operator-' + Date.now(),
                companyId: companyId,
                username: newUsername,
                password: newPassword,
                role: 'admin',
                createdAt: new Date().toISOString()
            });
        }

        this.showToast('Login actualizado exitosamente', 'success');
        this.closeModal('change-login-modal');

        // Enviar al backend para actualizar
        if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
            this.websocket.send(JSON.stringify({
                type: 'update_operators',
                data: this.data.operators
            }));
        }

        // Enviar al kiosco Flutter
        this.sendToKiosco({
            type: 'update_operators',
            data: this.data.operators
        });
    }
}

// Global functions for HTML onclick handlers
function showSection(sectionName) {
    dashboard.showSection(sectionName);
}

function showAddCompanyModal() {
    dashboard.showAddCompanyModal();
}

function showAddZoneModal() {
    dashboard.showAddZoneModal();
}

function closeModal(modalId) {
    dashboard.closeModal(modalId);
}

function refreshData() {
    dashboard.refreshData();
}

function exportSessions() {
    dashboard.exportSessions();
}

function saveSettings() {
    dashboard.saveSettings();
}

function toggleDarkMode() {
    dashboard.toggleDarkMode();
}

function toggleHighContrast() {
    dashboard.toggleHighContrast();
}

function changeFontSize() {
    dashboard.changeFontSize();
}

function toggleReduceAnimations() {
    dashboard.toggleReduceAnimations();
}

// Funciones para Modo Técnico
function refreshTechStatus() {
    dashboard.refreshTechStatus();
}

function runTechTest(testType) {
    dashboard.runTechTest(testType);
}

function resetDayCounters() {
    dashboard.resetDayCounters();
}

function reloadConfig() {
    dashboard.reloadConfig();
}

function rebootKioskApp() {
    dashboard.rebootKioskApp();
}

function restartKiosk() {
    dashboard.restartKiosk();
}

function closeKiosk() {
    dashboard.closeKiosk();
}

// Funciones para Operadores
function showAddOperatorModal() {
    dashboard.showAddOperatorModal();
}

// Funciones para Sesiones
function showExtendSessionModal() {
    dashboard.showExtendSessionModal();
}

function searchSessions() {
    dashboard.searchSessions();
}

function clearSessionSearch() {
    dashboard.clearSessionSearch();
}

// Funciones para Pagos
function showPaymentModal() {
    dashboard.showPaymentModal();
}

function simulatePayment() {
    dashboard.simulatePayment();
}

// Funciones para Tickets
function showGenerateTicketModal() {
    dashboard.showGenerateTicketModal();
}

function generateTicket() {
    dashboard.generateTicket();
}

function printAllTickets() {
    dashboard.printAllTickets();
}

// Función para Idioma
function changeLanguage() {
    const language = document.getElementById('language-select').value;
    dashboard.changeLanguage(language);
}

// Funciones globales para empresas
function editCompany(companyId) {
    dashboard.editCompany(companyId);
}

function deleteCompany(companyId) {
    dashboard.deleteCompany(companyId);
}

// Funciones globales para zonas
function editZone(zoneId) {
    dashboard.editZone(zoneId);
}

function deleteZone(zoneId) {
    dashboard.deleteZone(zoneId);
}

// Función para cerrar modales
function closeModal(modalId) {
    dashboard.closeModal(modalId);
}

// Función para mostrar modal de cambio de login
function showChangeLoginModal(companyId) {
    console.log('🔐 Función global showChangeLoginModal llamada con:', companyId);
    dashboard.showChangeLoginModal(companyId);
}

// Función de test para el modal
function testModal() {
    console.log('🧪 Probando modal...');
    const modal = document.getElementById('change-login-modal');
    if (modal) {
        modal.style.display = 'block';
        modal.classList.add('show');
        console.log('✅ Modal de test mostrado');
    } else {
        console.error('❌ Modal no encontrado');
    }
}

// Función para ajustar precios
function adjustPrice(amount) {
    const priceInput = document.getElementById('zone-price');
    const currentPrice = parseFloat(priceInput.value) || 0;
    const newPrice = Math.max(0, currentPrice + amount);
    priceInput.value = newPrice.toFixed(2);
}

// Initialize dashboard when page loads
let dashboard;
document.addEventListener('DOMContentLoaded', () => {
    dashboard = new MEYPARKDashboard();
});
