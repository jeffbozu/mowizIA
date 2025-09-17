import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'screens/login_screen.dart';
import 'screens/zone_screen.dart';
import 'screens/extend_screen.dart';
import 'screens/plate_screen.dart';
import 'screens/time_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/accessibility_screen.dart';
import 'screens/tech_screen.dart';
import 'screens/test_accessibility_screen.dart';
import 'modals/language_modal.dart';
import 'modals/admin_pass_modal.dart';
import 'modals/tech_pass_modal.dart';
import 'dashboard/screens/dashboard_home.dart';
import 'dashboard/screens/kiosco_monitor_screen.dart';
import 'web/screens/web_kiosco_home.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: kIsWeb ? '/web' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/zona',
        name: 'zona',
        builder: (context, state) => const ZoneScreen(),
      ),
      GoRoute(
        path: '/extender',
        name: 'extender',
        builder: (context, state) => const ExtendScreen(),
      ),
      GoRoute(
        path: '/matricula',
        name: 'matricula',
        builder: (context, state) => const PlateScreen(),
      ),
      GoRoute(
        path: '/tiempo',
        name: 'tiempo',
        builder: (context, state) => const TimeScreen(),
      ),
      GoRoute(
        path: '/pago',
        name: 'pago',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentScreen(
            isExtend: extra?['extend'] ?? false,
            minutes: extra?['minutos'] ?? extra?['minutosExtra'] ?? 0,
            price: extra?['precio'] ?? extra?['precioExtra'] ?? 0.0,
            zoneId: extra?['zonaId'] ?? '',
            plate: extra?['matricula'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/ticket',
        name: 'ticket',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TicketScreen(
            isExtend: extra?['extend'] ?? false,
            plate: extra?['matricula'] ?? '',
            zoneId: extra?['zonaId'] ?? '',
            minutes: extra?['minutos'] ?? extra?['minutosExtra'] ?? 0,
            price: extra?['precio'] ?? extra?['precioExtra'] ?? 0.0,
          );
        },
      ),
      GoRoute(
        path: '/accesibilidad',
        name: 'accesibilidad',
        builder: (context, state) => const AccessibilityScreen(),
      ),
      GoRoute(
        path: '/test-accesibilidad',
        name: 'test-accesibilidad',
        builder: (context, state) => const TestAccessibilityScreen(),
      ),
      GoRoute(
        path: '/tecnico',
        name: 'tecnico',
        builder: (context, state) => const TechScreen(),
      ),
      
      // Rutas del dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardHome(),
      ),
      GoRoute(
        path: '/dashboard/kiosco/:kioscoId',
        name: 'dashboard-kiosco',
        builder: (context, state) {
          final kioscoId = state.pathParameters['kioscoId']!;
          return KioscoMonitorScreen(kioscoId: kioscoId);
        },
      ),
      
      // Rutas de la versión web
      GoRoute(
        path: '/web',
        name: 'web-kiosco',
        builder: (context, state) => const WebKioscoHome(),
      ),
    ],
  );

  // Rutas modales (se abren con showDialog o showModalBottomSheet)
  static void showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const LanguageModal(),
    );
  }

  static void showAdminPassModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AdminPassModal(),
    );
  }

  static void showTechPassModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TechPassModal(),
    );
  }
}