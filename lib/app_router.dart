import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/zone_screen.dart';
import 'screens/extend_screen.dart';
import 'screens/plate_screen.dart';
import 'screens/time_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/accessibility_screen.dart';
import 'screens/tech_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/zona',
        builder: (context, state) => const ZoneScreen(),
      ),
      GoRoute(
        path: '/extender',
        builder: (context, state) => const ExtendScreen(),
      ),
      GoRoute(
        path: '/matricula',
        builder: (context, state) => const PlateScreen(),
      ),
      GoRoute(
        path: '/tiempo',
        builder: (context, state) => const TimeScreen(),
      ),
      GoRoute(
        path: '/pago',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/ticket',
        builder: (context, state) => const TicketScreen(),
      ),
      GoRoute(
        path: '/accesibilidad',
        builder: (context, state) => const AccessibilityScreen(),
      ),
      GoRoute(
        path: '/tecnico',
        builder: (context, state) => const TechScreen(),
      ),
    ],
  );
}
