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
      'access.font_size.info': 'El Tamaño de Texto permite ajustar el tamaño de todas las letras en la aplicación. Puedes elegir entre Pequeño (para pantallas grandes), Normal (tamaño estándar) o Grande (para mejor legibilidad). Esto afecta botones, títulos, descripciones y todos los textos de la interfaz.',
      'access.reduce_animations': 'Reducir Animaciones',
      'access.reduce_animations.desc': 'Reducir animaciones para mejor rendimiento',
      'access.reduce_animations.info': 'Reducir Animaciones desactiva o simplifica las transiciones y efectos visuales de la aplicación, mejorando el rendimiento en dispositivos más lentos y reduciendo la fatiga visual para usuarios sensibles al movimiento. Las pantallas cambiarán de forma más directa y rápida.',
      'access.dark_mode.desc': 'Cambiar entre tema claro y oscuro',
      'access.dark_mode.info': 'El Modo Oscuro cambia el tema de la aplicación a colores oscuros, reduciendo la fatiga visual en condiciones de poca luz. Los fondos se vuelven oscuros y el texto claro, proporcionando mejor contraste y comodidad para los ojos.',
      'access.high_contrast.desc': 'Aumentar contraste para mejor visibilidad',
      'access.high_contrast.info': 'El Alto Contraste aumenta significativamente la diferencia entre colores de texto y fondo, mejorando la legibilidad para usuarios con problemas de visión. Los textos se vuelven más nítidos y fáciles de leer.',
      'access.voice_guide': 'Guía por Voz',
      'access.voice_guide.desc': 'Navegación asistida por voz',
      'access.voice_guide.info': 'La Guía por Voz proporciona instrucciones de audio para cada pantalla y acción, ayudando a usuarios con discapacidad visual o que prefieren navegación por voz. La aplicación hablará automáticamente las opciones disponibles y confirmará las acciones realizadas.',
      'access.voice_speed': 'Velocidad de Voz',
      'access.voice_speed.desc': 'Ajustar velocidad del habla',
      'access.voice_speed.info': 'La Velocidad de Voz controla qué tan rápido habla la guía por voz. Puedes ajustarla desde muy lenta (10%) hasta muy rápida (100%) según tu preferencia y capacidad de comprensión.',
      'access.voice_pitch': 'Tono de Voz',
      'access.voice_pitch.desc': 'Ajustar tono del habla',
      'access.voice_pitch.info': 'El Tono de Voz ajusta la altura de la voz de la guía por voz. Puedes hacerla más grave (0.5x) o más aguda (2.0x) según tu preferencia auditiva.',
      'access.voice_volume': 'Volumen de Voz',
      'access.voice_volume.desc': 'Ajustar volumen del habla',
      'access.voice_volume.info': 'El Volumen de Voz controla qué tan fuerte se escucha la guía por voz. Puedes ajustarlo desde silencioso (0%) hasta volumen máximo (100%) según el ruido ambiente y tu preferencia.',
      
      // Funcionalidades avanzadas
      'access.adaptive_ai': 'IA Adaptativa',
      'access.adaptive_ai.desc': 'Aprende de tu comportamiento y se adapta automáticamente',
      'access.adaptive_ai.info': 'La IA Adaptativa aprende de cómo usas la aplicación y ajusta automáticamente la configuración de accesibilidad. Por ejemplo, si usas frecuentemente la guía por voz, la habilitará automáticamente. Si prefieres botones grandes, aumentará el tamaño de fuente. La IA también recordará tus zonas preferidas y te sugerirá opciones más rápidas.',
      
      'access.simplified_mode': 'Modo Simplificado',
      'access.simplified_mode.desc': 'Interfaz ultra-simple con menos opciones',
      'access.simplified_mode.info': 'El Modo Simplificado reduce la complejidad de la interfaz mostrando solo las opciones esenciales. Los botones son más grandes, el texto es más claro, y los pasos son más directos. Ideal para usuarios que prefieren una experiencia más simple y directa.',
      
      'access.apply': 'Aplicar',
      'access.back': 'Volver',

      // Voice Guide - Spanish
      'voice.zone.title': 'SELECCIONAR ZONA',
      'voice.zone.instruction': 'Seleccione una zona de estacionamiento tocando en la pantalla. En la siguiente pantalla deberá insertar la matrícula de su vehículo.',
      'voice.zone.selected': 'Zona seleccionada. Proceda a insertar la matrícula.',
      
      'voice.plate.title': 'INSERTAR MATRÍCULA',
      'voice.plate.instruction': 'Introduzca la matrícula de su vehículo usando el formato de cuatro números seguidos de tres letras. Por ejemplo: 1234ABC.',
      'voice.plate.valid': 'Matrícula válida. Proceda a seleccionar el tiempo de estacionamiento.',
      'voice.plate.invalid': 'Formato de matrícula inválido. Use el formato correcto.',
      
      'voice.time.title': 'SELECCIONAR TIEMPO',
      'voice.time.instruction': 'Seleccione el tiempo de estacionamiento usando los botones más y menos. El precio se calculará automáticamente.',
      'voice.time.selected': 'Tiempo seleccionado. Proceda al pago.',
      
      'voice.payment.title': 'REALIZAR PAGO',
      'voice.payment.instruction': 'Seleccione su método de pago preferido: monedas, tarjeta con chip y PIN, o pago sin contacto.',
      'voice.payment.coins': 'Inserte las monedas necesarias para completar el pago.',
      'voice.payment.card': 'Inserte su tarjeta y siga las instrucciones en pantalla.',
      'voice.payment.contactless': 'Acerca su tarjeta o dispositivo móvil al lector.',
      'voice.payment.complete': 'Pago completado. Su ticket está siendo generado.',
      
      'voice.ticket.title': 'TICKET GENERADO',
      'voice.ticket.instruction': 'Su ticket de estacionamiento ha sido generado. Colóquelo visiblemente en el parabrisas de su vehículo.',
      'voice.ticket.valid_until': 'Válido hasta la hora indicada en el ticket.',
      'voice.ticket.thank_you': 'Gracias por usar MEYPARK. ¡Buen viaje!',

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
      'access.font_size.info': 'Text Size allows you to adjust the size of all letters in the application. You can choose between Small (for large screens), Normal (standard size) or Large (for better readability). This affects buttons, titles, descriptions and all interface texts.',
      'access.reduce_animations': 'Reduce Animations',
      'access.reduce_animations.desc': 'Reduce animations for better performance',
      'access.reduce_animations.info': 'Reduce Animations disables or simplifies application transitions and visual effects, improving performance on slower devices and reducing visual fatigue for users sensitive to movement. Screens will change more directly and quickly.',
      'access.dark_mode.desc': 'Switch between light and dark theme',
      'access.dark_mode.info': 'Dark Mode changes the application theme to dark colors, reducing eye strain in low-light conditions. Backgrounds become dark and text becomes light, providing better contrast and comfort for the eyes.',
      'access.high_contrast.desc': 'Increase contrast for better visibility',
      'access.high_contrast.info': 'High Contrast significantly increases the difference between text and background colors, improving readability for users with vision problems. Text becomes sharper and easier to read.',
      'access.voice_guide': 'Voice Guide',
      'access.voice_guide.desc': 'Voice-assisted navigation',
      'access.voice_guide.info': 'Voice Guide provides audio instructions for each screen and action, helping users with visual impairments or those who prefer voice navigation. The application will automatically speak available options and confirm performed actions.',
      'access.voice_speed': 'Voice Speed',
      'access.voice_speed.desc': 'Adjust speech speed',
      'access.voice_speed.info': 'Voice Speed controls how fast the voice guide speaks. You can adjust it from very slow (10%) to very fast (100%) according to your preference and comprehension ability.',
      'access.voice_pitch': 'Voice Pitch',
      'access.voice_pitch.desc': 'Adjust speech pitch',
      'access.voice_pitch.info': 'Voice Pitch adjusts the pitch of the voice guide. You can make it deeper (0.5x) or higher (2.0x) according to your auditory preference.',
      'access.voice_volume': 'Voice Volume',
      'access.voice_volume.desc': 'Adjust speech volume',
      'access.voice_volume.info': 'Voice Volume controls how loud the voice guide sounds. You can adjust it from silent (0%) to maximum volume (100%) according to ambient noise and your preference.',
      
      // Advanced features
      'access.adaptive_ai': 'Adaptive AI',
      'access.adaptive_ai.desc': 'Learns from your behavior and adapts automatically',
      'access.adaptive_ai.info': 'Adaptive AI learns from how you use the application and automatically adjusts accessibility settings. For example, if you frequently use voice guidance, it will enable it automatically. If you prefer large buttons, it will increase font size. The AI will also remember your preferred zones and suggest faster options.',
      
      'access.simplified_mode': 'Simplified Mode',
      'access.simplified_mode.desc': 'Ultra-simple interface with fewer options',
      'access.simplified_mode.info': 'Simplified Mode reduces interface complexity by showing only essential options. Buttons are larger, text is clearer, and steps are more direct. Ideal for users who prefer a simpler and more direct experience.',
      
      'access.apply': 'Apply',
      'access.back': 'Back',

      // Voice Guide - English
      'voice.zone.title': 'SELECT ZONE',
      'voice.zone.instruction': 'Select a parking zone by touching the screen. On the next screen you will need to enter your vehicle license plate.',
      'voice.zone.selected': 'Zone selected. Please proceed to enter your license plate.',
      
      'voice.plate.title': 'ENTER LICENSE PLATE',
      'voice.plate.instruction': 'Enter your vehicle license plate using the format of four numbers followed by three letters. For example: 1234ABC.',
      'voice.plate.valid': 'Valid license plate. Please proceed to select parking time.',
      'voice.plate.invalid': 'Invalid license plate format. Please use the correct format.',
      
      'voice.time.title': 'SELECT TIME',
      'voice.time.instruction': 'Select parking time using the plus and minus buttons. The price will be calculated automatically.',
      'voice.time.selected': 'Time selected. Please proceed to payment.',
      
      'voice.payment.title': 'MAKE PAYMENT',
      'voice.payment.instruction': 'Select your preferred payment method: coins, chip and PIN card, or contactless payment.',
      'voice.payment.coins': 'Insert the necessary coins to complete the payment.',
      'voice.payment.card': 'Insert your card and follow the on-screen instructions.',
      'voice.payment.contactless': 'Bring your card or mobile device close to the reader.',
      'voice.payment.complete': 'Payment completed. Your ticket is being generated.',
      
      'voice.ticket.title': 'TICKET GENERATED',
      'voice.ticket.instruction': 'Your parking ticket has been generated. Please place it visibly on your vehicle windshield.',
      'voice.ticket.valid_until': 'Valid until the time indicated on the ticket.',
      'voice.ticket.thank_you': 'Thank you for using MEYPARK. Have a great trip!',

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