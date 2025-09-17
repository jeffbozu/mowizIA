import 'dart:async';

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
      primaryColor: json['primaryColor'] ?? '#E62144',
      backgroundColor: json['backgroundColor'] ?? '#FFFFFF',
      logoUrl: json['logoUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryColor': primaryColor,
      'backgroundColor': backgroundColor,
      'logoUrl': logoUrl,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class Operator {
  final String id;
  final String companyId;
  final String name;
  final String username;
  final String password;
  final bool isActive;

  const Operator({
    required this.id,
    required this.companyId,
    required this.name,
    required this.username,
    required this.password,
    this.isActive = true,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'username': username,
      'password': password,
      'isActive': isActive,
    };
  }
}

class Zone {
  final String id;
  final String companyId;
  final String name;
  final String color;
  final double pricePerHour;
  final int maxHours;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  const Zone({
    required this.id,
    required this.companyId,
    required this.name,
    required this.color,
    required this.pricePerHour,
    required this.maxHours,
    required this.description,
    this.isActive = true,
    required this.createdAt,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#2196F3',
      pricePerHour: (json['pricePerHour'] ?? 0.0).toDouble(),
      maxHours: json['maxHours'] ?? 4,
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'color': color,
      'pricePerHour': pricePerHour,
      'maxHours': maxHours,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Session {
  final String plate;
  final String zoneId;
  final DateTime start;
  final DateTime end;
  final double totalPrice;
  final String? paymentMethod;

  const Session({
    required this.plate,
    required this.zoneId,
    required this.start,
    required this.end,
    required this.totalPrice,
    this.paymentMethod,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
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

  Session copyWith({
    String? plate,
    String? zoneId,
    DateTime? start,
    DateTime? end,
    double? totalPrice,
    String? paymentMethod,
  }) {
    return Session(
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
  static Map<String, Session> activeSessions = {};
  static PaymentContext? currentPayment;
  static Operator? currentOperator;
  
  // Configuración de WebSocket
  static String? kioscoId;
  static bool isConnectedToDashboard = false;
  
  // Streams para notificar cambios
  static final StreamController<void> _accessibilityController = StreamController<void>.broadcast();
  static final StreamController<void> _configController = StreamController<void>.broadcast();
  static final StreamController<void> _websocketController = StreamController<void>.broadcast();
  
  static Stream<void> get accessibilityStream => _accessibilityController.stream;
  static Stream<void> get configStream => _configController.stream;
  static Stream<void> get websocketStream => _websocketController.stream;
  
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
  
  // Métodos para gestión de datos
  static void setCurrentCompany(Company company) {
    currentCompany = company;
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
  
  static void dispose() {
    _accessibilityController.close();
    _configController.close();
    _websocketController.close();
  }
}