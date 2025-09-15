class Operator {
  final String id;
  final String name;
  final String username;
  final String password;
  final List<Zone> zones;

  const Operator({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.zones,
  });
}

class Zone {
  final String id;
  final String name;
  final String color;
  final double pricePerHour;
  final int maxHours;
  final String operatorId;

  const Zone({
    required this.id,
    required this.name,
    required this.color,
    required this.pricePerHour,
    required this.maxHours,
    required this.operatorId,
  });
}

class Session {
  final String plate;
  final String zoneId;
  final DateTime start;
  final DateTime end;
  final double totalAmount;

  const Session({
    required this.plate,
    required this.zoneId,
    required this.start,
    required this.end,
    required this.totalAmount,
  });
}

class PaymentContext {
  final bool isExtend;
  final String plate;
  final String zoneId;
  final int minutes;
  final double amount;
  final DateTime endTime;

  const PaymentContext({
    required this.isExtend,
    required this.plate,
    required this.zoneId,
    required this.minutes,
    required this.amount,
    required this.endTime,
  });
}
