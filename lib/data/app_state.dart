import 'models.dart';

class AppState {
  static Operator? _currentOperator;
  static Zone? _selectedZone;
  static PaymentContext? _paymentContext;

  static Operator? get currentOperator => _currentOperator;
  static Zone? get selectedZone => _selectedZone;
  static PaymentContext? get paymentContext => _paymentContext;

  static void setCurrentOperator(Operator? operator) {
    _currentOperator = operator;
  }

  static void setSelectedZone(Zone? zone) {
    _selectedZone = zone;
  }

  static void setPaymentContext(PaymentContext? context) {
    _paymentContext = context;
  }

  static void clearState() {
    _currentOperator = null;
    _selectedZone = null;
    _paymentContext = null;
  }
}
