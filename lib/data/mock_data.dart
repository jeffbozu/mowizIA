import 'models.dart';

class MockData {
  // Operadores mock
  static const List<Operator> operators = [
    Operator(
      id: 'mowiz',
      name: 'MOWIZ',
      username: 'mowiz_admin',
      password: 'Mo2025!',
      zones: [
        Zone(
          id: 'MZ-A',
          name: 'MZ-A (Azul)',
          color: 'blue',
          pricePerHour: 1.20,
          maxHours: 4,
          operatorId: 'mowiz',
        ),
        Zone(
          id: 'MZ-V',
          name: 'MZ-V (Verde)',
          color: 'green',
          pricePerHour: 2.10,
          maxHours: 2,
          operatorId: 'mowiz',
        ),
      ],
    ),
    Operator(
      id: 'eypsa',
      name: 'EYPSA',
      username: 'eypsa_admin',
      password: 'Ey2025!',
      zones: [
        Zone(
          id: 'EY-A',
          name: 'EY-A (Azul)',
          color: 'blue',
          pricePerHour: 1.50,
          maxHours: 4,
          operatorId: 'eypsa',
        ),
        Zone(
          id: 'EY-V',
          name: 'EY-V (Verde)',
          color: 'green',
          pricePerHour: 2.40,
          maxHours: 2,
          operatorId: 'eypsa',
        ),
        Zone(
          id: 'EY-R',
          name: 'EY-R (Residente)',
          color: 'orange',
          pricePerHour: 0.50,
          maxHours: 24,
          operatorId: 'eypsa',
        ),
      ],
    ),
  ];

  // Sesiones activas mock
  static final Map<String, Session> activeSessions = {
    '1234ABC': Session(
      plate: '1234ABC',
      zoneId: 'MZ-A',
      start: DateTime.now().subtract(const Duration(minutes: 30)),
      end: DateTime.now().add(const Duration(minutes: 45)),
      totalAmount: 1.20,
    ),
    '5678DEF': Session(
      plate: '5678DEF',
      zoneId: 'EY-V',
      start: DateTime.now().subtract(const Duration(minutes: 15)),
      end: DateTime.now().add(const Duration(minutes: 15)),
      totalAmount: 2.40,
    ),
  };

  // Validar credenciales
  static Operator? validateCredentials(String username, String password) {
    for (final operator in operators) {
      if (operator.username == username && operator.password == password) {
        return operator;
      }
    }
    return null;
  }

  // Obtener operador por ID
  static Operator? getOperatorById(String id) {
    for (final operator in operators) {
      if (operator.id == id) {
        return operator;
      }
    }
    return null;
  }

  // Obtener zona por ID
  static Zone? getZoneById(String id) {
    for (final operator in operators) {
      for (final zone in operator.zones) {
        if (zone.id == id) {
          return zone;
        }
      }
    }
    return null;
  }

  // Obtener sesión por matrícula
  static Session? getSessionByPlate(String plate) {
    return activeSessions[plate];
  }

  // Validar matrícula (regex: ^\d{4}[A-Z]{3}$)
  static bool isValidPlate(String plate) {
    final regex = RegExp(r'^\d{4}[A-Z]{3}$');
    return regex.hasMatch(plate);
  }

  // Calcular precio
  static double calculatePrice(double pricePerHour, int minutes) {
    final hours = minutes / 60.0;
    final price = pricePerHour * hours;
    return double.parse(price.toStringAsFixed(2));
  }

  // Obtener color de zona
  static int getZoneColor(String color) {
    switch (color) {
      case 'blue':
        return 0xFF2196F3;
      case 'green':
        return 0xFF4CAF50;
      case 'orange':
        return 0xFFFF9800;
      default:
        return 0xFF7F7F7F;
    }
  }
}
