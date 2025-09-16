import 'models.dart';

class MockData {
  // Datos mock para empresas
  static List<Company> companies = [
    Company(
      id: 'mowiz-company',
      name: 'MOWIZ Parking',
      primaryColor: '#E62144',
      backgroundColor: '#FFFFFF',
      logoUrl: '',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Company(
      id: 'eypsa-company',
      name: 'EYPSA Estacionamientos',
      primaryColor: '#2196F3',
      backgroundColor: '#F5F5F5',
      logoUrl: '',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  static List<Operator> operators = [
    Operator(
      id: 'mowiz-admin',
      companyId: 'mowiz-company',
      name: 'MOWIZ Admin',
      username: 'mowiz_admin',
      password: 'Mo2025!',
    ),
    Operator(
      id: 'eypsa-admin',
      companyId: 'eypsa-company',
      name: 'EYPSA Admin',
      username: 'eypsa_admin',
      password: 'Ey2025!',
    ),
  ];

  static List<Zone> zones = [
    // MOWIZ zones
    Zone(
      id: 'MZ-A',
      companyId: 'mowiz-company',
      name: 'MZ-A (Azul)',
      color: '#2196F3',
      pricePerHour: 1.20,
      maxHours: 4,
      description: 'Zona azul - Centro comercial',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Zone(
      id: 'MZ-V',
      companyId: 'mowiz-company',
      name: 'MZ-V (Verde)',
      color: '#4CAF50',
      pricePerHour: 2.10,
      maxHours: 2,
      description: 'Zona verde - Área residencial',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    // EYPSA zones
    Zone(
      id: 'EY-A',
      companyId: 'eypsa-company',
      name: 'EY-A (Azul)',
      color: '#2196F3',
      pricePerHour: 1.50,
      maxHours: 4,
      description: 'Zona azul - Distrito financiero',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Zone(
      id: 'EY-V',
      companyId: 'eypsa-company',
      name: 'EY-V (Verde)',
      color: '#4CAF50',
      pricePerHour: 2.40,
      maxHours: 2,
      description: 'Zona verde - Zona turística',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Zone(
      id: 'EY-R',
      companyId: 'eypsa-company',
      name: 'EY-R (Residente)',
      color: '#FF9800',
      pricePerHour: 0.50,
      maxHours: 24, // 1 día
      description: 'Zona residente - Solo con etiqueta',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  // Sesiones activas mock
  static Map<String, Session> activeSessions = {
    '1234ABC': Session(
      plate: '1234ABC',
      zoneId: 'MZ-A',
      start: DateTime.now().subtract(const Duration(minutes: 15)),
      end: DateTime.now().add(const Duration(minutes: 45)),
      totalPrice: 1.20,
    ),
    '5678DEF': Session(
      plate: '5678DEF',
      zoneId: 'EY-V',
      start: DateTime.now().subtract(const Duration(minutes: 30)),
      end: DateTime.now().add(const Duration(minutes: 30)),
      totalPrice: 1.20,
    ),
  };

  // Función para inicializar datos mock
  static void initializeMockData() {
    // Agregar empresas al estado
    for (final company in companies) {
      AppState.addCompany(company);
    }
    
    // Agregar operadores al estado
    for (final operator in operators) {
      AppState.addOperator(operator);
    }
    
    // Agregar zonas al estado
    for (final zone in zones) {
      AppState.addZone(zone);
    }
    
    // Agregar sesiones activas al estado
    AppState.activeSessions.addAll(activeSessions);
    
    // Establecer empresa por defecto
    if (AppState.companies.isNotEmpty) {
      AppState.setCurrentCompany(AppState.companies.values.first);
    }
  }

  // Métodos de utilidad para validación y cálculos
  static bool validatePlate(String plate) {
    // Validar formato: 4 números + 3 letras
    final regex = RegExp(r'^\d{4}[A-Z]{3}$');
    return regex.hasMatch(plate);
  }

  static Session? getSessionByPlate(String plate) {
    return AppState.activeSessions[plate];
  }

  static Zone? getZoneById(String zoneId) {
    return AppState.zones[zoneId];
  }

  static double calculatePrice(double pricePerHour, int minutes) {
    // Calcular precio exacto
    final exactPrice = pricePerHour * (minutes / 60);
    // Redondear a 2 decimales
    return double.parse(exactPrice.toStringAsFixed(2));
  }

  static int getMaxExtraMinutes(String zoneId, int currentMinutes) {
    final zone = getZoneById(zoneId);
    if (zone == null) return 0;
    
    final maxTotalMinutes = zone.maxHours * 60;
    return maxTotalMinutes - currentMinutes;
  }

  static void addSession(Session session) {
    AppState.activeSessions[session.plate] = session;
  }

  static void removeSession(String plate) {
    AppState.activeSessions.remove(plate);
  }

  // Función de prueba para verificar cálculos
  static void testPriceCalculations() {
    print('=== PRUEBAS DE CÁLCULO DE PRECIOS ===');
    
    // MOWIZ - MZ-V (2.10€/h)
    print('MOWIZ MZ-V (2.10€/h):');
    print('  1h = ${calculatePrice(2.10, 60)}€ (debería ser 2.10€)');
    print('  2h = ${calculatePrice(2.10, 120)}€ (debería ser 4.20€)');
    print('  30m = ${calculatePrice(2.10, 30)}€ (debería ser 1.05€)');
    
    // EYPSA - EY-V (2.40€/h)
    print('EYPSA EY-V (2.40€/h):');
    print('  1h = ${calculatePrice(2.40, 60)}€ (debería ser 2.40€)');
    print('  2h = ${calculatePrice(2.40, 120)}€ (debería ser 4.80€)');
    print('  15m = ${calculatePrice(2.40, 15)}€ (debería ser 0.60€)');
    
    // EYPSA - EY-R (0.50€/h)
    print('EYPSA EY-R (0.50€/h):');
    print('  1h = ${calculatePrice(0.50, 60)}€ (debería ser 0.50€)');
    print('  2h = ${calculatePrice(0.50, 120)}€ (debería ser 1.00€)');
    print('  3h = ${calculatePrice(0.50, 180)}€ (debería ser 1.50€)');
  }

  // Funciones para actualizar datos desde el dashboard
  static void updateOperators(List<Map<String, dynamic>> operatorsData) {
    operators.clear();
    for (var opData in operatorsData) {
      final operator = Operator(
        id: opData['id'],
        companyId: opData['companyId'],
        name: opData['name'] ?? opData['username'],
        username: opData['username'],
        password: opData['password'],
      );
      operators.add(operator);
    }
  }

  static void updateCompanies(List<Map<String, dynamic>> companiesData) {
    companies.clear();
    for (var compData in companiesData) {
      final company = Company(
        id: compData['id'],
        name: compData['name'],
        primaryColor: compData['color'] ?? compData['primaryColor'] ?? '#E62144',
        backgroundColor: compData['bgColor'] ?? compData['backgroundColor'] ?? '#FFFFFF',
        logoUrl: compData['logoUrl'] ?? '',
        createdAt: DateTime.tryParse(compData['createdAt'] ?? '') ?? DateTime.now(),
      );
      companies.add(company);
    }
  }

  static void updateZones(List<Map<String, dynamic>> zonesData) {
    zones.clear();
    for (var zoneData in zonesData) {
      final zone = Zone(
        id: zoneData['id'],
        companyId: zoneData['companyId'],
        name: zoneData['name'],
        color: zoneData['color'] ?? '#2196F3',
        pricePerHour: (zoneData['pricePerHour'] ?? zoneData['price'] ?? 0.0).toDouble(),
        maxHours: zoneData['maxHours'] ?? 24,
        description: zoneData['description'] ?? 'Zona de estacionamiento',
        createdAt: DateTime.tryParse(zoneData['createdAt'] ?? '') ?? DateTime.now(),
      );
      zones.add(zone);
    }
  }
}