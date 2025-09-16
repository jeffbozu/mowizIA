import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../app_router.dart';
import '../modals/admin_pass_modal.dart';
import '../modals/tech_pass_modal.dart';
import '../data/models.dart';
import '../services/websocket_service.dart';

class TopBar extends StatefulWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBack;

  const TopBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AdminPassModal(),
      );
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
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const TechPassModal(),
          );
        }
      }
    }
  }

  String _getCompanyShortName() {
    final companyName = AppState.currentCompany?.name ?? 'MEYPARK';
    
    // Extraer solo la primera palabra del nombre de la empresa
    if (companyName.contains(' ')) {
      return companyName.split(' ').first;
    }
    
    return companyName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                if (widget.showBackButton) ...[
                  IconButton(
                    onPressed: widget.onBack ?? () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: 28,
                  ),
                  const SizedBox(width: 8),
                ],
                // Logo con gestos
                Flexible(
                  child: GestureDetector(
                    onTap: _handleLogoTap,
                    onLongPressStart: (_) => _handleLongPressStart(),
                    onLongPressEnd: (_) => _handleLongPressEnd(),
                    child: Text(
                      _getCompanyShortName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (widget.title != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Estado de conexión WebSocket
          StreamBuilder<bool>(
            stream: WebSocketService.connectionStream,
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
              );
            },
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
                onPressed: () => AppRouter.showLanguageModal(context),
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
    );
  }
}