import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models.dart';
import '../../i18n/strings.dart';
import '../../widgets/top_bar.dart';
import '../../modals/admin_pass_modal.dart';
import '../../modals/tech_pass_modal.dart';
import '../../modals/language_modal.dart';

class WebKioscoHome extends StatefulWidget {
  const WebKioscoHome({super.key});

  @override
  State<WebKioscoHome> createState() => _WebKioscoHomeState();
}

class _WebKioscoHomeState extends State<WebKioscoHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra superior personalizada para web
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Logo y título
                Expanded(
                  child: Row(
                    children: [
                      // Logo con gestos (solo para web)
                      GestureDetector(
                        onTap: _handleLogoTap,
                        onLongPressStart: (_) => _handleLongPressStart(),
                        onLongPressEnd: (_) => _handleLongPressEnd(),
                        child: Text(
                          AppState.currentCompany?.name ?? 'MEYPARK',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Versión Web',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estado de conexión
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.cloud_done,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                // Botones de accesibilidad e idioma
                Row(
                  children: [
                    // Botón Accesibilidad
                    IconButton(
                      onPressed: () => context.push('/accesibilidad'),
                      icon: const Text('🧩', style: TextStyle(fontSize: 24)),
                      tooltip: AppStrings.t('access.title'),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón Idioma
                    IconButton(
                      onPressed: () => _showLanguageModal(),
                      icon: const Text('🌐', style: TextStyle(fontSize: 24)),
                      tooltip: AppStrings.t('lang.title'),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo grande
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.local_parking,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          // Título principal
          Text(
            'MEYPARK Web',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          // Subtítulo
          Text(
            'Sistema de parquímetro digital',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 48),
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Nuevo Estacionamiento
              SizedBox(
                width: 200,
                height: 60,
                child: FilledButton.icon(
                  onPressed: () => context.go('/zona'),
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  label: Text(
                    'Nuevo Estacionamiento',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Botón Extender Sesión
              SizedBox(
                width: 200,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/extender'),
                  icon: const Icon(Icons.schedule, size: 24),
                  label: Text(
                    'Extender Sesión',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Versión Web del Kiosco',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta es la versión web del kiosco MEYPARK. '
                  'Puedes usar esta interfaz desde cualquier dispositivo '
                  'con conexión a internet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gestos para acceso técnico (similares a la versión Linux)
  int _logoTaps = 0;
  DateTime? _lastLogoTap;
  bool _isLongPressing = false;
  DateTime? _longPressStartTime;

  void _handleLogoTap() {
    final now = DateTime.now();
    
    // Resetear contador si han pasado más de 7 segundos
    if (_lastLogoTap != null && now.difference(_lastLogoTap!).inSeconds > 7) {
      _logoTaps = 0;
    }

    _logoTaps++;
    _lastLogoTap = now;

    // Si hay 5 toques en 7 segundos, abrir modal admin
    if (_logoTaps >= 5) {
      _logoTaps = 0;
      _showAdminPassModal();
    }
  }

  void _handleLongPressStart() {
    _isLongPressing = true;
    _longPressStartTime = DateTime.now();
    
    // Mostrar indicador visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mantén presionado para acceso técnico...'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _handleLongPressEnd() {
    if (_isLongPressing) {
      _isLongPressing = false;
      
      // Verificar si se mantuvo presionado por al menos 3 segundos
      if (_longPressStartTime != null) {
        final duration = DateTime.now().difference(_longPressStartTime!);
        if (duration.inSeconds >= 3) {
          _showTechPassModal();
        }
      }
    }
  }

  void _showAdminPassModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AdminPassModal(),
    );
  }

  void _showTechPassModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TechPassModal(),
    );
  }

  void _showLanguageModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const LanguageModal(),
    );
  }
}

