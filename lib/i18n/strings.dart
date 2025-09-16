import '../data/models.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    'es-ES': {
      // Login
      'login.title': 'Iniciar Sesión',
      'login.subtitle': 'Sistema de Gestión de Aparcamiento',
      'login.operator.mowiz': 'MOWIZ',
      'login.operator.eypsa': 'EYPSA',
      'login.username': 'Usuario',
      'login.password': 'Contraseña',
      'login.submit': 'Iniciar Sesión',
      'login.error': 'Credenciales inválidas',
      'login.invalid_credentials': 'Credenciales inválidas',
      'login.welcome': '¡Bienvenido',

      // Zone
      'zone.title': 'Seleccionar Zona',
      'zone.extend': 'Extender Sesión',
      'zone.next': 'Siguiente',
      'zone.price_per_hour': '€/h',
      'zone.max_hours': 'máx {hours}h',

      // Plate
      'plate.title': 'Matrícula',
      'plate.hint': 'Ej: 1234ABC',
      'plate.clear': 'Borrar',
      'plate.back': 'Atrás',
      'plate.next': 'Siguiente',
      'plate.invalid_format': 'Formato inválido. Use: 1234ABC',
      'plate.valid': 'Matrícula válida',

      // Time
      'time.title': 'Tiempo de Estacionamiento',
      'time.until': 'Válido hasta',
      'time.total': 'Total',
      'time.plus': '+',
      'time.minus': '−',
      'time.pay': 'Ir a Pago',
      'time.quick_select': 'Selección Rápida',

      // Payment
      'pay.title': 'Pago',
      'pay.method.cash': 'Monedas',
      'pay.method.chip': 'Chip+PIN',
      'pay.method.contactless': 'Contactless',
      'pay.inserted': 'Insertado',
      'pay.remaining': 'Falta',
      'pay.pay_now': 'Pagar Ahora',
      'pay.cancel': 'Cancelar',
      'pay.authorizing': 'Autorizando...',
      'pay.authorized': 'Autorizado',
      'pay.new_parking': 'Nuevo Estacionamiento',
      'pay.extend_session': 'Extender Sesión',
      'pay.zone': 'Zona',
      'pay.duration': 'Duración',
      'pay.total': 'Total',
      'pay.select_method': 'Seleccionar Método',
      'pay.insert_coins': 'Insertar Monedas',

      // Ticket
      'ticket.title.new': 'Estacionamiento Registrado',
      'ticket.title.extend': 'Extensión Realizada',
      'ticket.print': 'Imprimir Ticket',
      'ticket.ok': 'OK',
      'ticket.new_parking': 'Nuevo Estacionamiento',
      'ticket.details': 'Detalles',
      'ticket.plate': 'Matrícula',
      'ticket.zone': 'Zona',
      'ticket.start': 'Inicio',
      'ticket.end': 'Fin',
      'ticket.amount': 'Importe',
      'ticket.previous_end': 'Fin anterior',
      'ticket.new_end': 'Nuevo fin',
      'ticket.extra_amount': 'Importe adicional',

      // Accessibility
      'access.title': 'Accesibilidad',
      'access.dark_mode': 'Modo Oscuro',
      'access.high_contrast': 'Alto Contraste',
      'access.font_size': 'Tamaño de Texto',
      'access.font_size.small': 'Pequeño',
      'access.font_size.normal': 'Normal',
      'access.font_size.large': 'Grande',
      'access.font_size.desc': 'Ajustar el tamaño del texto',
      'access.reduce_animations': 'Reducir Animaciones',
      'access.reduce_animations.desc': 'Reducir animaciones para mejor rendimiento',
      'access.dark_mode.desc': 'Cambiar entre tema claro y oscuro',
      'access.high_contrast.desc': 'Aumentar contraste para mejor visibilidad',
      'access.apply': 'Aplicar',
      'access.back': 'Volver',

      // Language
      'lang.title': 'Idioma',
      'lang.es': 'Español (España)',
      'lang.en': 'English',
      'lang.save': 'Guardar',
      'lang.cancel': 'Cancelar',

      // Admin Pass
      'admin.title': 'Acceso Administrador',
      'admin.password': 'Contraseña',
      'admin.access': 'Acceder',
      'admin.cancel': 'Cancelar',
      'admin.invalid_password': 'Contraseña incorrecta',

      // Tech Pass
      'techpass.title': 'Acceso Técnico',
      'techpass.password': 'Contraseña',
      'techpass.enter': 'Entrar',
      'techpass.cancel': 'Cancelar',
      'techpass.invalid_password': 'Contraseña incorrecta',

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
      'tech.reload_config': 'Forzar Recarga',
      'tech.reboot_app': 'Reiniciar App',
      'tech.close': 'Cerrar',
      'tech.network': 'Red',
      'tech.printer': 'Impresora',
      'tech.coin_acceptor': 'Aceptador Monedas',
      'tech.card_reader': 'Lector Tarjeta',
      'tech.temperature': 'Temperatura',
      'tech.door': 'Puerta',
      'tech.transactions_today': 'Transacciones hoy',
      'tech.cash_income': 'Ingresos efectivo',
      'tech.card_income': 'Ingresos tarjeta',
      'tech.last_sync': 'Última sincronización',
      'tech.active_operator': 'Operador activo',

      // Extend
      'extend.title': 'Extender Sesión',
      'extend.search': 'Buscar',
      'extend.no_session': 'No hay sesión activa para esta matrícula',
      'extend.back_to_zones': 'Volver a Zonas',
      'extend.start_new': 'Iniciar Nuevo',
      'extend.current_end': 'Fin actual',
      'extend.remaining': 'Tiempo restante',
      'extend.extra_time': 'Tiempo extra',
      'extend.new_end': 'Nuevo fin',
      'extend.extra_amount': 'Importe adicional',
      'extend.go_pay': 'Ir a Pago',
      'extend.max_reached': 'Tiempo máximo alcanzado',

      // Common
      'common.loading': 'Cargando...',
      'common.error': 'Error',
      'common.success': 'Éxito',
      'common.confirm': 'Confirmar',
      'common.yes': 'Sí',
      'common.no': 'No',
      'common.ok': 'OK',
      'common.cancel': 'Cancelar',
      'common.save': 'Guardar',
      'common.back': 'Atrás',
      'common.next': 'Siguiente',
      'common.finish': 'Finalizar',
    },
    'en': {
      // Login
      'login.title': 'Log In',
      'login.subtitle': 'Parking Management System',
      'login.operator.mowiz': 'MOWIZ',
      'login.operator.eypsa': 'EYPSA',
      'login.username': 'Username',
      'login.password': 'Password',
      'login.submit': 'Log In',
      'login.error': 'Invalid credentials',
      'login.invalid_credentials': 'Invalid credentials',
      'login.welcome': 'Welcome',

      // Zone
      'zone.title': 'Select Zone',
      'zone.extend': 'Extend Session',
      'zone.next': 'Next',
      'zone.price_per_hour': '€/h',
      'zone.max_hours': 'max {hours}h',

      // Plate
      'plate.title': 'License Plate',
      'plate.hint': 'Ex: 1234ABC',
      'plate.clear': 'Clear',
      'plate.back': 'Back',
      'plate.next': 'Next',
      'plate.invalid_format': 'Invalid format. Use: 1234ABC',
      'plate.valid': 'Valid plate',

      // Time
      'time.title': 'Parking Time',
      'time.until': 'Valid until',
      'time.total': 'Total',
      'time.plus': '+',
      'time.minus': '−',
      'time.pay': 'Go to Payment',
      'time.quick_select': 'Quick Select',

      // Payment
      'pay.title': 'Payment',
      'pay.method.cash': 'Coins',
      'pay.method.chip': 'Chip+PIN',
      'pay.method.contactless': 'Contactless',
      'pay.inserted': 'Inserted',
      'pay.remaining': 'Remaining',
      'pay.pay_now': 'Pay Now',
      'pay.cancel': 'Cancel',
      'pay.authorizing': 'Authorizing...',
      'pay.authorized': 'Authorized',
      'pay.new_parking': 'New Parking',
      'pay.extend_session': 'Extend Session',
      'pay.zone': 'Zone',
      'pay.duration': 'Duration',
      'pay.total': 'Total',
      'pay.select_method': 'Select Method',
      'pay.insert_coins': 'Insert Coins',

      // Ticket
      'ticket.title.new': 'Parking Registered',
      'ticket.title.extend': 'Extension Completed',
      'ticket.print': 'Print Ticket',
      'ticket.ok': 'OK',
      'ticket.new_parking': 'New Parking',
      'ticket.details': 'Details',
      'ticket.plate': 'License Plate',
      'ticket.zone': 'Zone',
      'ticket.start': 'Start',
      'ticket.end': 'End',
      'ticket.amount': 'Amount',
      'ticket.previous_end': 'Previous end',
      'ticket.new_end': 'New end',
      'ticket.extra_amount': 'Extra amount',

      // Accessibility
      'access.title': 'Accessibility',
      'access.dark_mode': 'Dark Mode',
      'access.high_contrast': 'High Contrast',
      'access.font_size': 'Text Size',
      'access.font_size.small': 'Small',
      'access.font_size.normal': 'Normal',
      'access.font_size.large': 'Large',
      'access.font_size.desc': 'Adjust text size',
      'access.reduce_animations': 'Reduce Animations',
      'access.reduce_animations.desc': 'Reduce animations for better performance',
      'access.dark_mode.desc': 'Switch between light and dark theme',
      'access.high_contrast.desc': 'Increase contrast for better visibility',
      'access.apply': 'Apply',
      'access.back': 'Back',

      // Language
      'lang.title': 'Language',
      'lang.es': 'Español (España)',
      'lang.en': 'English',
      'lang.save': 'Save',
      'lang.cancel': 'Cancel',

      // Admin Pass
      'admin.title': 'Admin Access',
      'admin.password': 'Password',
      'admin.access': 'Access',
      'admin.cancel': 'Cancel',
      'admin.invalid_password': 'Incorrect password',

      // Tech Pass
      'techpass.title': 'Tech Access',
      'techpass.password': 'Password',
      'techpass.enter': 'Enter',
      'techpass.cancel': 'Cancel',
      'techpass.invalid_password': 'Incorrect password',

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
      'tech.reload_config': 'Force Reload',
      'tech.reboot_app': 'Reboot App',
      'tech.close': 'Close',
      'tech.network': 'Network',
      'tech.printer': 'Printer',
      'tech.coin_acceptor': 'Coin Acceptor',
      'tech.card_reader': 'Card Reader',
      'tech.temperature': 'Temperature',
      'tech.door': 'Door',
      'tech.transactions_today': 'Transactions today',
      'tech.cash_income': 'Cash income',
      'tech.card_income': 'Card income',
      'tech.last_sync': 'Last sync',
      'tech.active_operator': 'Active operator',

      // Extend
      'extend.title': 'Extend Session',
      'extend.search': 'Search',
      'extend.no_session': 'No active session for this license plate',
      'extend.back_to_zones': 'Back to Zones',
      'extend.start_new': 'Start New',
      'extend.current_end': 'Current end',
      'extend.remaining': 'Remaining time',
      'extend.extra_time': 'Extra time',
      'extend.new_end': 'New end',
      'extend.extra_amount': 'Extra amount',
      'extend.go_pay': 'Go to Payment',
      'extend.max_reached': 'Maximum time reached',

      // Common
      'common.loading': 'Loading...',
      'common.error': 'Error',
      'common.success': 'Success',
      'common.confirm': 'Confirm',
      'common.yes': 'Yes',
      'common.no': 'No',
      'common.ok': 'OK',
      'common.cancel': 'Cancel',
      'common.save': 'Save',
      'common.back': 'Back',
      'common.next': 'Next',
      'common.finish': 'Finish',
    },
  };

  static String t(String key, {Map<String, String>? params}) {
    final language = AppState.currentLanguage;
    final strings = _strings[language] ?? _strings['es-ES']!;
    String value = strings[key] ?? key;

    // Reemplazar parámetros si existen
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }

    return value;
  }

  static void changeLanguage(String languageCode) {
    if (_strings.containsKey(languageCode)) {
      AppState.currentLanguage = languageCode;
      AppState.notifyAccessibilityChange();
    }
  }

  static List<String> get availableLanguages => _strings.keys.toList();
}