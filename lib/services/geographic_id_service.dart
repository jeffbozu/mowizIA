import 'dart:convert';
import 'dart:io';

class GeographicIdService {
  static const String _kioskIdKey = 'kiosk_geographic_id';
  static const String _kioskLocationKey = 'kiosk_location';
  
  // Códigos de ciudades españolas principales
  static const Map<String, String> cityCodes = {
    'MAD': 'Madrid',
    'BCN': 'Barcelona', 
    'VLC': 'Valencia',
    'SEV': 'Sevilla',
    'ZAR': 'Zaragoza',
    'MAL': 'Málaga',
    'MUR': 'Murcia',
    'PAL': 'Palma',
    'BIL': 'Bilbao',
    'COR': 'Córdoba',
    'VIG': 'Vigo',
    'GIR': 'Girona',
    'LPA': 'Las Palmas',
    'SCT': 'Santa Cruz de Tenerife',
    'OVI': 'Oviedo',
    'VIT': 'Vitoria',
    'SAL': 'Salamanca',
    'ALB': 'Albacete',
    'BUR': 'Burgos',
    'LEO': 'León'
  };
  
  // Zonas típicas dentro de las ciudades
  static const Map<String, List<String>> zoneTypes = {
    'MAD': ['Centro', 'Chamartin', 'Salamanca', 'Retiro', 'Chueca', 'Lavapies', 'Malasaña', 'CondeDuque'],
    'BCN': ['Eixample', 'Gotic', 'Born', 'Gracia', 'PobleNou', 'Sants', 'PobleSec', 'Raval'],
    'VLC': ['Centro', 'Eixample', 'Ruzafa', 'Campanar', 'Benimaclet', 'Patraix', 'Nazaret', 'Orriols'],
    'SEV': ['Centro', 'Triana', 'Nervion', 'LosRemedios', 'Macarena', 'Alameda', 'SanBernardo', 'PoligonoSur'],
    'ZAR': ['Centro', 'Delicias', 'Actur', 'Valdespartera', 'Torrero', 'Oliver', 'SanJose', 'LasFuentes']
  };
  
  /// Genera un ID geográfico para el kiosko
  static Future<String> generateGeographicId({
    String? cityCode,
    String? zone,
    String? customName,
  }) async {
    // Generar nuevo ID geográfico
    String newId;
    
    if (customName != null && customName.isNotEmpty) {
      // ID personalizado
      newId = _sanitizeId(customName);
    } else {
      // ID geográfico automático
      final selectedCity = cityCode ?? _getRandomCity();
      final selectedZone = zone ?? _getRandomZone(selectedCity);
      final kioskNumber = _generateKioskNumber();
      
      newId = '${selectedCity}_${selectedZone}_K${kioskNumber}';
    }
    
    print('🏢 ID Geográfico generado: $newId');
    return newId;
  }
  
  /// Obtiene el ID actual del kiosko
  static Future<String?> getCurrentId() async {
    // Por ahora retorna null, se implementará con SharedPreferences más tarde
    return null;
  }
  
  /// Actualiza el ID del kiosko
  static Future<String> updateId(String newId) async {
    print('🔄 ID actualizado: $newId');
    return newId;
  }
  
  /// Obtiene información de ubicación del ID
  static Future<Map<String, String>> getLocationInfo() async {
    return {
      'city': 'Desconocida',
      'zone': 'Desconocida',
      'fullName': 'Kiosko sin ubicación'
    };
  }
  
  /// Valida si un ID es válido
  static bool isValidGeographicId(String id) {
    // Formato: CIUDAD_ZONA_K## o nombre personalizado
    final pattern = RegExp(r'^[A-Z]{3}_[A-Za-z]+_K\d{2}$|^[A-Za-z0-9_-]+$');
    return pattern.hasMatch(id);
  }
  
  /// Obtiene lista de ciudades disponibles
  static List<Map<String, String>> getAvailableCities() {
    return cityCodes.entries.map((entry) => {
      'code': entry.key,
      'name': entry.value
    }).toList();
  }
  
  /// Obtiene zonas de una ciudad
  static List<String> getZonesForCity(String cityCode) {
    return zoneTypes[cityCode] ?? ['Centro'];
  }
  
  // Métodos privados
  
  static String _getRandomCity() {
    final cities = cityCodes.keys.toList();
    return cities[DateTime.now().millisecondsSinceEpoch % cities.length];
  }
  
  static String _getRandomZone(String cityCode) {
    final zones = zoneTypes[cityCode] ?? ['Centro'];
    return zones[DateTime.now().millisecondsSinceEpoch % zones.length];
  }
  
  static String _generateKioskNumber() {
    return (DateTime.now().millisecondsSinceEpoch % 99 + 1).toString().padLeft(2, '0');
  }
  
  static String _sanitizeId(String id) {
    return id
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9_-]'), '')
        .replaceAll(' ', '_');
  }
  
  static Future<void> _saveLocationInfo(String id) async {
    // Implementación simplificada sin SharedPreferences
    print('📍 Ubicación guardada para ID: $id');
  }
}
