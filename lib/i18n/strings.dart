class AppStrings {
  static const String _defaultLocale = 'es-ES';
  static String _currentLocale = _defaultLocale;
  
  static String get currentLocale => _currentLocale;
  
  static void setLocale(String locale) {
    _currentLocale = locale;
  }
  
  static String t(String key) {
    final strings = _getStringsForLocale(_currentLocale);
    return strings[key] ?? key;
  }
  
  static Map<String, String> _getStringsForLocale(String locale) {
    switch (locale) {
      case 'en':
        return _englishStrings;
      case 'es-ES':
      default:
        return _spanishStrings;
    }
  }
  
  static const Map<String, String> _spanishStrings = {
    // Login
    'login.title': 'Iniciar Sesión',
    'login.operator.mowiz': 'MOWIZ',
    'login.operator.eypsa': 'EYPSA',
    'login.username': 'Usuario',
    'login.password': 'Contraseña',
    'login.submit': 'Iniciar Sesión',
    
    // Zone
    'zone.title': 'Seleccionar Zona',
    'zone.extend': 'Extender Sesión',
    'zone.next': 'Siguiente',
    
    // Plate
    'plate.title': 'Matrícula del Vehículo',
    'plate.hint': 'Ej: 1234ABC',
    'plate.clear': 'Borrar',
    'plate.back': 'Atrás',
    'plate.next': 'Siguiente',
    
    // Time
    'time.title': 'Tiempo de Estacionamiento',
    'time.until': 'Válido hasta',
    'time.total': 'Total',
    'time.plus': '+',
    'time.minus': '-',
    'time.pay': 'Ir a Pago',
    
    // Payment
    'pay.title': 'Método de Pago',
    'pay.method.cash': 'Monedas',
    'pay.method.chip': 'Chip + PIN',
    'pay.method.contactless': 'Contactless',
    'pay.inserted': 'Insertado',
    'pay.remaining': 'Falta',
    'pay.pay_now': 'Pagar Ahora',
    'pay.cancel': 'Cancelar',
    
    // Ticket
    'ticket.title.new': 'Estacionamiento Registrado',
    'ticket.title.extend': 'Extensión Realizada',
    'ticket.print': 'Imprimir Ticket',
    'ticket.ok': 'OK',
    'ticket.new_parking': 'Nuevo Estacionamiento',
    
    // Accessibility
    'access.title': 'Accesibilidad',
    'access.dark_mode': 'Modo Oscuro',
    'access.high_contrast': 'Alto Contraste',
    'access.apply': 'Aplicar',
    'access.back': 'Volver',
    
    // Language
    'lang.title': 'Idioma',
    'lang.es': 'Español (España)',
    'lang.en': 'English',
    'lang.save': 'Guardar',
    'lang.cancel': 'Cancelar',
    
    // Admin
    'admin.title': 'Acceso Administrador',
    'admin.password': 'Contraseña',
    'admin.access': 'Acceder',
    'admin.cancel': 'Cancelar',
    
    // Tech Pass
    'techpass.title': 'Acceso Técnico',
    'techpass.password': 'Contraseña',
    'techpass.enter': 'Entrar',
    'techpass.cancel': 'Cancelar',
    
    // Tech
    'tech.title': 'Modo Técnico',
    'tech.status': 'Estado del Sistema',
    'tech.refresh': 'Refrescar',
    'tech.tests': 'Diagnósticos',
    'tech.counters': 'Contadores',
    'tech.config': 'Configuración',
    'tech.actions': 'Acciones',
    'tech.test.display': 'Test Pantalla',
    'tech.test.touch': 'Test Táctil',
    'tech.test.printer': 'Test Impresora',
    'tech.test.coins': 'Test Monedas',
    'tech.test.card': 'Test Tarjeta',
    'tech.counter.reset_day': 'Reiniciar Día',
    'tech.reload_config': 'Recargar Config',
    'tech.reboot_app': 'Reiniciar App',
    'tech.close': 'Cerrar',
    
    // Extend
    'extend.title': 'Extender Sesión',
    'extend.search': 'Buscar',
    'extend.no_session': 'No hay sesión activa',
    'extend.back_to_zones': 'Volver a Zonas',
    'extend.start_new': 'Iniciar Nuevo',
    'extend.current_end': 'Fin actual',
    'extend.remaining': 'Tiempo restante',
    'extend.extra_time': 'Tiempo extra',
    'extend.new_end': 'Nuevo fin',
    'extend.extra_amount': 'Importe adicional',
    'extend.go_pay': 'Ir a Pago',
  };
  
  static const Map<String, String> _englishStrings = {
    // Login
    'login.title': 'Login',
    'login.operator.mowiz': 'MOWIZ',
    'login.operator.eypsa': 'EYPSA',
    'login.username': 'Username',
    'login.password': 'Password',
    'login.submit': 'Login',
    
    // Zone
    'zone.title': 'Select Zone',
    'zone.extend': 'Extend Session',
    'zone.next': 'Next',
    
    // Plate
    'plate.title': 'Vehicle Plate',
    'plate.hint': 'Ex: 1234ABC',
    'plate.clear': 'Clear',
    'plate.back': 'Back',
    'plate.next': 'Next',
    
    // Time
    'time.title': 'Parking Time',
    'time.until': 'Valid until',
    'time.total': 'Total',
    'time.plus': '+',
    'time.minus': '-',
    'time.pay': 'Go to Payment',
    
    // Payment
    'pay.title': 'Payment Method',
    'pay.method.cash': 'Coins',
    'pay.method.chip': 'Chip + PIN',
    'pay.method.contactless': 'Contactless',
    'pay.inserted': 'Inserted',
    'pay.remaining': 'Remaining',
    'pay.pay_now': 'Pay Now',
    'pay.cancel': 'Cancel',
    
    // Ticket
    'ticket.title.new': 'Parking Registered',
    'ticket.title.extend': 'Extension Completed',
    'ticket.print': 'Print Ticket',
    'ticket.ok': 'OK',
    'ticket.new_parking': 'New Parking',
    
    // Accessibility
    'access.title': 'Accessibility',
    'access.dark_mode': 'Dark Mode',
    'access.high_contrast': 'High Contrast',
    'access.apply': 'Apply',
    'access.back': 'Back',
    
    // Language
    'lang.title': 'Language',
    'lang.es': 'Spanish (Spain)',
    'lang.en': 'English',
    'lang.save': 'Save',
    'lang.cancel': 'Cancel',
    
    // Admin
    'admin.title': 'Admin Access',
    'admin.password': 'Password',
    'admin.access': 'Access',
    'admin.cancel': 'Cancel',
    
    // Tech Pass
    'techpass.title': 'Tech Access',
    'techpass.password': 'Password',
    'techpass.enter': 'Enter',
    'techpass.cancel': 'Cancel',
    
    // Tech
    'tech.title': 'Tech Mode',
    'tech.status': 'System Status',
    'tech.refresh': 'Refresh',
    'tech.tests': 'Diagnostics',
    'tech.counters': 'Counters',
    'tech.config': 'Configuration',
    'tech.actions': 'Actions',
    'tech.test.display': 'Display Test',
    'tech.test.touch': 'Touch Test',
    'tech.test.printer': 'Printer Test',
    'tech.test.coins': 'Coins Test',
    'tech.test.card': 'Card Test',
    'tech.counter.reset_day': 'Reset Day',
    'tech.reload_config': 'Reload Config',
    'tech.reboot_app': 'Reboot App',
    'tech.close': 'Close',
    
    // Extend
    'extend.title': 'Extend Session',
    'extend.search': 'Search',
    'extend.no_session': 'No active session',
    'extend.back_to_zones': 'Back to Zones',
    'extend.start_new': 'Start New',
    'extend.current_end': 'Current end',
    'extend.remaining': 'Remaining time',
    'extend.extra_time': 'Extra time',
    'extend.new_end': 'New end',
    'extend.extra_amount': 'Additional amount',
    'extend.go_pay': 'Go to Payment',
  };
}
