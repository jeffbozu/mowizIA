import 'dart:async';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';
import '../services/supabase_realtime_service.dart';
import '../services/dynamic_translations_service.dart';

// Modelo para empresas personalizables
class Company {
  final String id;
  final String name;
  final String primaryColor;
  final String backgroundColor;
  final String logoUrl;
  final DateTime createdAt;
  final bool isActive;

  const Company({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.backgroundColor,
    required this.logoUrl,
    required this.createdAt,
    this.isActive = true,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      primaryColor: json['primary_color'] ?? '#E62144', // Supabase usa snake_case
      backgroundColor: json['background_color'] ?? '#FFFFFF',
      logoUrl: json['logo_url'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primary_color': primaryColor, // Supabase usa snake_case
      'background_color': backgroundColor,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}

class Operator {
  final String id;
  final String companyId;
  final String name;
  final String username;
  final String passwordHash; // Cambiado a passwordHash para Supabase
  final String role;
  final List<String> permissions;
  final bool isActive;

  const Operator({
    required this.id,
    required this.companyId,
    required this.name,
    required this.username,
    required this.passwordHash,
    this.role = 'operator',
    this.permissions = const [],
    this.isActive = true,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'] ?? '',
      companyId: json['company_id'] ?? '', // Supabase usa snake_case
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      passwordHash: json['password_hash'] ?? '',
      role: json['role'] ?? 'operator',
      permissions: List<String>.from(json['permissions'] ?? []),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId, // Supabase usa snake_case
      'name': name,
      'username': username,
      'password_hash': passwordHash,
      'role': role,
      'permissions': permissions,
      'is_active': isActive,
    };
  }
}

class Zone {
  final String id;
  final String companyId;
  final String name;
  final String color;
  final double pricePerHour;
  final int maxDuration; // Duración máxima en minutos
  final String description;
  final bool isActive;
  final DateTime createdAt;
  // Configuración de tiempo
  final List<int> timeOptions; // Opciones de tiempo disponibles (en minutos)
  final int timeIncrement; // Incremento mínimo de tiempo (en minutos)
  final int minTime; // Tiempo mínimo (en minutos)

  const Zone({
    required this.id,
    required this.companyId,
    required this.name,
    required this.color,
    required this.pricePerHour,
    required this.maxDuration,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    this.timeOptions = const [15, 30, 60, 120, 180, 240], // 15m, 30m, 1h, 2h, 3h, 4h
    this.timeIncrement = 15, // Incremento de 15 minutos
    this.minTime = 15, // Mínimo 15 minutos
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? '',
      companyId: json['company_id'] ?? '', // Supabase usa snake_case
      name: json['name'] ?? '',
      color: json['color'] ?? '#2196F3',
      pricePerHour: (json['price_per_hour'] ?? 0.0).toDouble(), // Supabase usa snake_case
      maxDuration: json['max_duration'] ?? 240, // Supabase usa snake_case
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true, // Supabase usa snake_case
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()), // Supabase usa snake_case
      timeOptions: (json['time_options'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [15, 30, 60, 120, 180, 240], // Supabase usa snake_case
      timeIncrement: json['time_increment'] ?? 15, // Supabase usa snake_case
      minTime: json['min_time'] ?? 15, // Supabase usa snake_case
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId, // Supabase usa snake_case
      'name': name,
      'color': color,
      'price_per_hour': pricePerHour, // Supabase usa snake_case
      'max_duration': maxDuration, // Supabase usa snake_case
      'description': description,
      'is_active': isActive, // Supabase usa snake_case
      'created_at': createdAt.toIso8601String(), // Supabase usa snake_case
      'time_options': timeOptions, // Supabase usa snake_case
      'time_increment': timeIncrement, // Supabase usa snake_case
      'min_time': minTime, // Supabase usa snake_case
    };
  }
}

class ParkingSession {
  final String plate;
  final String zoneId;
  final DateTime start;
  final DateTime end;
  final double totalPrice;
  final String? paymentMethod;

  const ParkingSession({
    required this.plate,
    required this.zoneId,
    required this.start,
    required this.end,
    required this.totalPrice,
    this.paymentMethod,
  });

  factory ParkingSession.fromJson(Map<String, dynamic> json) {
    return ParkingSession(
      plate: json['plate'] ?? '',
      zoneId: json['zoneId'] ?? '',
      start: DateTime.parse(json['start'] ?? DateTime.now().toIso8601String()),
      end: DateTime.parse(json['end'] ?? DateTime.now().toIso8601String()),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plate': plate,
      'zoneId': zoneId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
    };
  }

  ParkingSession copyWith({
    String? plate,
    String? zoneId,
    DateTime? start,
    DateTime? end,
    double? totalPrice,
    String? paymentMethod,
  }) {
    return ParkingSession(
      plate: plate ?? this.plate,
      zoneId: zoneId ?? this.zoneId,
      start: start ?? this.start,
      end: end ?? this.end,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  int get remainingMinutes {
    final now = DateTime.now();
    if (now.isAfter(end)) return 0;
    return end.difference(now).inMinutes;
  }

  int get consumedMinutes {
    final now = DateTime.now();
    if (now.isBefore(start)) return 0;
    return now.difference(start).inMinutes;
  }
}

class PaymentContext {
  final bool isExtend;
  final String plate;
  final String zoneId;
  final int minutes;
  final double price;
  final double insertedAmount;
  final String paymentMethod;

  const PaymentContext({
    required this.isExtend,
    required this.plate,
    required this.zoneId,
    required this.minutes,
    required this.price,
    this.insertedAmount = 0.0,
    this.paymentMethod = 'cash',
  });

  PaymentContext copyWith({
    bool? isExtend,
    String? plate,
    String? zoneId,
    int? minutes,
    double? price,
    double? insertedAmount,
    String? paymentMethod,
  }) {
    return PaymentContext(
      isExtend: isExtend ?? this.isExtend,
      plate: plate ?? this.plate,
      zoneId: zoneId ?? this.zoneId,
      minutes: minutes ?? this.minutes,
      price: price ?? this.price,
      insertedAmount: insertedAmount ?? this.insertedAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class AppState {
  // Configuración de empresa actual
  static Company? currentCompany;
  static String? currentOperatorId;
  static String? selectedZoneId;
  
  // Configuración de accesibilidad
  static bool darkMode = false;
  static bool highContrast = false;
  static String currentLanguage = 'es-ES';
  static String fontSize = 'normal'; // 'small', 'normal', 'large'
  static bool reduceAnimations = false;
  static bool voiceGuideEnabled = false;
  
  // Configuración de guía por voz
  static double voiceSpeed = 0.5; // 0.1 - 1.0
  static double voicePitch = 1.0; // 0.5 - 2.0
  static double voiceVolume = 0.8; // 0.0 - 1.0
  
  // Funcionalidades avanzadas de accesibilidad
  static bool adaptiveAI = false; // IA adaptativa
  static bool simplifiedMode = false; // Modo simplificado
  
  // Datos de IA adaptativa
  static Map<String, int> userBehavior = {}; // Comportamiento del usuario
  static Map<String, dynamic> userPreferences = {}; // Preferencias aprendidas
  static List<String> mostUsedFeatures = []; // Características más usadas
  
  // Datos dinámicos
  static Map<String, Company> companies = {};
  static Map<String, Operator> operators = {};
  static Map<String, Zone> zones = {};
  static Map<String, ParkingSession> activeSessions = {};
  static PaymentContext? currentPayment;
  static Operator? currentOperator;
  static String? currentPlate;
  
  // Configuración de WebSocket
  static String? kioscoId;
  static bool isConnectedToDashboard = false;
  
  // Estadísticas
  static double totalIncome = 0.0;
  static double todayIncome = 0.0;
  static int activeSessionsCount = 0;
  
  // Configuración de pagos (cargada desde Supabase)
  static List<double> acceptedCoins = []; // Se carga desde Supabase
  static List<String> acceptedCards = []; // Se carga desde Supabase
  static double maxChangeAmount = 0.0; // Se carga desde Supabase
  static double minPaymentAmount = 0.0; // Se carga desde Supabase
  static String currency = ''; // Se carga desde Supabase
  static String currencySymbol = ''; // Se carga desde Supabase
  
  // Configuración del kiosco
  static String kioscoLocation = 'Centro Comercial';
  static String timezone = 'Europe/Madrid';
  static bool maintenanceMode = false;
  
  // Streams para notificar cambios
  static final StreamController<void> _accessibilityController = StreamController<void>.broadcast();
  static final StreamController<void> _configController = StreamController<void>.broadcast();
  static final StreamController<void> _websocketController = StreamController<void>.broadcast();
  static final StreamController<String> _languageController = StreamController<String>.broadcast();
  
  static Stream<void> get accessibilityStream => _accessibilityController.stream;
  static Stream<void> get configStream => _configController.stream;
  static Stream<void> get websocketStream => _websocketController.stream;
  static Stream<String> get languageStream => _languageController.stream;
  
  // Métodos para notificar cambios
  static void notifyAccessibilityChange() {
    _accessibilityController.add(null);
  }
  
  static void notifyConfigChange() {
    _configController.add(null);
  }
  
  static void notifyWebSocketChange() {
    _websocketController.add(null);
  }
  
  static void notifyLanguageChange(String language) {
    _languageController.add(language);
  }
  
  // Métodos para gestión de datos
  static void setCurrentCompany(Company company) {
    currentCompany = company;
    notifyConfigChange();
  }
  
  static void setCurrentPlate(String? plate) {
    currentPlate = plate;
    notifyConfigChange();
  }
  
  static void addCompany(Company company) {
    companies[company.id] = company;
    notifyConfigChange();
  }
  
  static void addOperator(Operator operator) {
    operators[operator.id] = operator;
    notifyConfigChange();
  }
  
  static void addZone(Zone zone) {
    zones[zone.id] = zone;
    notifyConfigChange();
  }
  
  static List<Operator> getOperatorsForCompany(String companyId) {
    return operators.values.where((op) => op.companyId == companyId && op.isActive).toList();
  }
  
  static List<Zone> getZonesForCompany(String companyId) {
    return zones.values.where((zone) => zone.companyId == companyId && zone.isActive).toList();
  }
  
  // Métodos para IA adaptativa
  static void learnUserBehavior(String action) {
    if (!adaptiveAI) return;
    
    userBehavior[action] = (userBehavior[action] ?? 0) + 1;
    
    // Actualizar características más usadas
    final sortedEntries = userBehavior.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    mostUsedFeatures = sortedEntries
        .take(5)
        .map((e) => e.key)
        .toList();
    
    // Aprender preferencias automáticamente
    _learnPreferences(action);
    
    print('🧠 IA Adaptativa: Aprendido comportamiento - $action (${userBehavior[action]} veces)');
  }
  
  static void _learnPreferences(String action) {
    // Aprender preferencias basadas en comportamiento
    switch (action) {
      case 'voice_guide_used':
        if (userBehavior[action]! > 3) {
          userPreferences['prefers_voice'] = true;
        }
        break;
      case 'large_buttons_used':
        if (userBehavior[action]! > 2) {
          userPreferences['prefers_large_ui'] = true;
        }
        break;
      case 'simplified_mode_used':
        if (userBehavior[action]! > 1) {
          userPreferences['prefers_simple'] = true;
        }
        break;
      case 'zone_selected':
        // Aprender zona preferida
        final zoneId = selectedZoneId;
        if (zoneId != null) {
          userPreferences['preferred_zone'] = zoneId;
        }
        break;
    }
  }
  
  static void applyLearnedPreferences() {
    if (!adaptiveAI) return;
    
    // Aplicar preferencias aprendidas
    if (userPreferences['prefers_voice'] == true && !voiceGuideEnabled) {
      voiceGuideEnabled = true;
      print('🧠 IA: Habilitando guía por voz basada en comportamiento');
    }
    
    if (userPreferences['prefers_large_ui'] == true && fontSize != 'large') {
      fontSize = 'large';
      print('🧠 IA: Aumentando tamaño de fuente basado en comportamiento');
    }
    
    if (userPreferences['prefers_simple'] == true && !simplifiedMode) {
      simplifiedMode = true;
      print('🧠 IA: Habilitando modo simplificado basado en comportamiento');
    }
    
    notifyAccessibilityChange();
  }
  
  static void resetAdaptiveAI() {
    userBehavior.clear();
    userPreferences.clear();
    mostUsedFeatures.clear();
    print('🧠 IA Adaptativa: Datos de aprendizaje reiniciados');
  }
  
  // Inicializar empresa por defecto
  static void initializeDefaultCompany() {
    if (currentCompany == null) {
      // Establecer MOWIZ como empresa por defecto
      currentCompany = Company(
        id: 'mowiz-company',
        name: 'MOWIZ',
        primaryColor: '#E62144',
        backgroundColor: '#FFFFFF',
        logoUrl: '',
        createdAt: DateTime.now(),
        isActive: true,
      );
      print('🏢 Empresa por defecto establecida: MOWIZ');
    }
  }
  
  // ===========================================
  // MÉTODOS BÁSICOS DE ALMACENAMIENTO
  // ===========================================
  
  /// Guardar configuración básica
  static Future<void> saveConfig() async {
    try {
      await LocalStorageService.saveConfig();
      print('💾 Configuración guardada localmente');
    } catch (e) {
      print('❌ Error guardando configuración: $e');
    }
  }
  
  /// Cargar configuración básica
  static Future<void> loadConfig() async {
    try {
      await LocalStorageService.loadConfig();
      print('📂 Configuración cargada localmente');
    } catch (e) {
      print('❌ Error cargando configuración: $e');
    }
  }
  
  // ========================================
  // MÉTODOS DE SUPABASE
  // ========================================
  
  /// Cargar todos los datos desde Supabase
  static Future<void> loadFromSupabase() async {
    try {
      print('🔄 Cargando datos desde Supabase...');
      
      // Cargar empresas
      await _loadCompanies();
      
      // Cargar operadores
      await _loadOperators();
      
      // Cargar zonas
      await _loadZones();
      
      // Cargar configuración de pagos
      await _loadPaymentConfig();
      
      // Cargar configuración de accesibilidad
      await _loadAccessibilityConfig();
      
      // Cargar sesiones activas
      await _loadActiveSessions();
      
      // Configurar empresa por defecto si no hay ninguna
      if (currentCompany == null && companies.isNotEmpty) {
        currentCompany = companies.values.first;
        print('🏢 Empresa por defecto establecida: ${currentCompany!.name}');
      }
      
      // Notificar cambios
      notifyConfigChange();
      
      print('✅ Datos cargados desde Supabase correctamente');
      
    } catch (e) {
      print('❌ Error cargando datos desde Supabase: $e');
      // NO usar fallback - TODO debe venir de Supabase según las reglas
      rethrow;
    }
  }
  
  /// Cargar empresas desde Supabase
  static Future<void> _loadCompanies() async {
    try {
      final companiesList = await SupabaseService.instance.getCompanies();
      companies.clear();
      
      for (final company in companiesList) {
        companies[company.id] = company;
      }
      
      print('📊 Empresas cargadas: ${companies.length}');
      
    } catch (e) {
      print('❌ Error cargando empresas: $e');
    }
  }
  
  /// Cargar operadores desde Supabase
  static Future<void> _loadOperators() async {
    try {
      if (currentCompany == null) return;
      
      final operatorsList = await SupabaseService.instance.getOperatorsByCompany(currentCompany!.id);
      operators.clear();
      
      for (final operator in operatorsList) {
        operators[operator.id] = operator;
      }
      
      print('👥 Operadores cargados: ${operators.length}');
      
    } catch (e) {
      print('❌ Error cargando operadores: $e');
    }
  }
  
  /// Cargar zonas desde Supabase
  static Future<void> _loadZones() async {
    try {
      if (currentCompany == null) return;
      
      final zonesList = await SupabaseService.instance.getZonesByCompany(currentCompany!.id);
      zones.clear();
      
      for (final zone in zonesList) {
        zones[zone.id] = zone;
      }
      
      print('🅿️ Zonas cargadas: ${zones.length}');
      
    } catch (e) {
      print('❌ Error cargando zonas: $e');
    }
  }
  
  /// Cargar configuración de pagos desde Supabase
  static Future<void> _loadPaymentConfig() async {
    try {
      if (currentCompany == null) return;
      
      final config = await SupabaseService.instance.getCompanyCompleteConfig(currentCompany!.id);
      if (config != null) {
        acceptedCoins = List<double>.from(config['accepted_coins'] ?? []);
        acceptedCards = List<String>.from(config['accepted_cards'] ?? []);
        maxChangeAmount = (config['max_change_amount'] ?? 10.0).toDouble();
        minPaymentAmount = (config['min_payment_amount'] ?? 0.15).toDouble();
        currency = config['currency'] ?? 'EUR';
        currencySymbol = config['currency_symbol'] ?? '€';
        
        print('💳 Configuración de pagos cargada');
      }
      
    } catch (e) {
      print('❌ Error cargando configuración de pagos: $e');
    }
  }
  
  /// Cargar configuración de accesibilidad desde Supabase
  static Future<void> _loadAccessibilityConfig() async {
    try {
      if (currentCompany == null) return;
      
      final config = await SupabaseService.instance.getCompanyCompleteConfig(currentCompany!.id);
      if (config != null) {
        darkMode = config['dark_mode'] ?? false;
        highContrast = config['high_contrast'] ?? false;
        fontSize = config['font_size'] ?? 'normal';
        reduceAnimations = config['reduce_animations'] ?? false;
        voiceGuideEnabled = config['voice_guide'] ?? false;
        voiceSpeed = (config['voice_speed'] ?? 0.5).toDouble();
        voicePitch = (config['voice_pitch'] ?? 1.0).toDouble();
        voiceVolume = (config['voice_volume'] ?? 0.8).toDouble();
        adaptiveAI = config['adaptive_ai'] ?? false;
        simplifiedMode = config['simplified_mode'] ?? false;
        currentLanguage = config['current_language'] ?? 'es-ES';
        
        print('♿ Configuración de accesibilidad cargada');
      }
      
    } catch (e) {
      print('❌ Error cargando configuración de accesibilidad: $e');
    }
  }
  
  /// Cargar sesiones activas desde Supabase
  static Future<void> _loadActiveSessions() async {
    try {
      final sessionsList = await SupabaseService.instance.getActiveSessions();
      activeSessions.clear();
      
      for (final session in sessionsList) {
        activeSessions[session.plate] = session;
      }
      
      activeSessionsCount = activeSessions.length;
      
      print('📋 Sesiones activas cargadas: ${activeSessions.length}');
      
    } catch (e) {
      print('❌ Error cargando sesiones activas: $e');
    }
  }
  
  /// Cargar datos por defecto como fallback - ELIMINADO
  /// Según las reglas: TODO debe venir de Supabase, NO datos hardcodeados
  static void _loadDefaultData() {
    print('❌ ERROR: No se pueden cargar datos hardcodeados');
    print('❌ TODO debe venir de Supabase según las reglas establecidas');
    throw Exception('Sistema configurado para depender únicamente de Supabase');
  }
  
  /// Notificar cambios (método unificado)
  static void notifyListeners() {
    notifyConfigChange();
    notifyAccessibilityChange();
  }
  
  /// Cambiar empresa actual
  static Future<void> changeCompany(String companyId) async {
    try {
      final company = companies[companyId];
      if (company != null) {
        currentCompany = company;
        
        // Recargar datos específicos de la empresa
        await _loadOperators();
        await _loadZones();
        await _loadPaymentConfig();
        await _loadAccessibilityConfig();
        
        // Cambiar traducciones
        await DynamicTranslationsService.instance.changeCompany(companyId);
        
        notifyListeners();
        
        print('🏢 Empresa cambiada a: ${company.name}');
      }
    } catch (e) {
      print('❌ Error cambiando empresa: $e');
    }
  }
  
  /// Recargar datos desde Supabase
  static Future<void> reloadFromSupabase() async {
    await loadFromSupabase();
  }
  
  static void dispose() {
    _accessibilityController.close();
    _configController.close();
    _websocketController.close();
    _languageController.close();
  }
}

// Modelos para facturación electrónica
class ElectronicInvoiceTransaction {
  final String id;
  final String plate;
  final String zoneId;
  final DateTime timestamp;
  final double amount;
  final String paymentMethod;
  final String kioscoId;
  final bool isExtend;
  final int minutes;
  final String? invoiceId; // ID de la factura generada
  final DateTime? invoiceGeneratedAt;
  final String? invoiceUrl;

  const ElectronicInvoiceTransaction({
    required this.id,
    required this.plate,
    required this.zoneId,
    required this.timestamp,
    required this.amount,
    required this.paymentMethod,
    required this.kioscoId,
    required this.isExtend,
    required this.minutes,
    this.invoiceId,
    this.invoiceGeneratedAt,
    this.invoiceUrl,
  });

  factory ElectronicInvoiceTransaction.fromJson(Map<String, dynamic> json) {
    return ElectronicInvoiceTransaction(
      id: json['id'] ?? '',
      plate: json['plate'] ?? '',
      zoneId: json['zoneId'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      kioscoId: json['kioscoId'] ?? '',
      isExtend: json['isExtend'] ?? false,
      minutes: json['minutes'] ?? 0,
      invoiceId: json['invoiceId'],
      invoiceGeneratedAt: json['invoiceGeneratedAt'] != null 
          ? DateTime.parse(json['invoiceGeneratedAt']) 
          : null,
      invoiceUrl: json['invoiceUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate': plate,
      'zoneId': zoneId,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'paymentMethod': paymentMethod,
      'kioscoId': kioscoId,
      'isExtend': isExtend,
      'minutes': minutes,
      'invoiceId': invoiceId,
      'invoiceGeneratedAt': invoiceGeneratedAt?.toIso8601String(),
      'invoiceUrl': invoiceUrl,
    };
  }

  ElectronicInvoiceTransaction copyWith({
    String? id,
    String? plate,
    String? zoneId,
    DateTime? timestamp,
    double? amount,
    String? paymentMethod,
    String? kioscoId,
    bool? isExtend,
    int? minutes,
    String? invoiceId,
    DateTime? invoiceGeneratedAt,
    String? invoiceUrl,
  }) {
    return ElectronicInvoiceTransaction(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      zoneId: zoneId ?? this.zoneId,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      kioscoId: kioscoId ?? this.kioscoId,
      isExtend: isExtend ?? this.isExtend,
      minutes: minutes ?? this.minutes,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceGeneratedAt: invoiceGeneratedAt ?? this.invoiceGeneratedAt,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
    );
  }
}

class InvoiceRequest {
  final String transactionId;
  final String nif;
  final String companyName;
  final String address;
  final String city;
  final String postalCode;
  final String email;
  final String? phone;

  const InvoiceRequest({
    required this.transactionId,
    required this.nif,
    required this.companyName,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.email,
    this.phone,
  });

  factory InvoiceRequest.fromJson(Map<String, dynamic> json) {
    return InvoiceRequest(
      transactionId: json['transactionId'] ?? '',
      nif: json['nif'] ?? '',
      companyName: json['companyName'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'nif': nif,
      'companyName': companyName,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'email': email,
      'phone': phone,
    };
  }
}

class InvoiceResponse {
  final bool success;
  final String? invoiceId;
  final String? invoiceUrl;
  final String? errorMessage;

  const InvoiceResponse({
    required this.success,
    this.invoiceId,
    this.invoiceUrl,
    this.errorMessage,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      success: json['success'] ?? false,
      invoiceId: json['invoiceId'],
      invoiceUrl: json['invoiceUrl'],
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'invoiceId': invoiceId,
      'invoiceUrl': invoiceUrl,
      'errorMessage': errorMessage,
    };
  }
}