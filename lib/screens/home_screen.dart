import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../app_router.dart';
import '../data/models.dart';
import '../services/websocket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    
    // Enviar datos de pantalla al dashboard
    WebSocketService.sendScreenUpdate('home', 
      user: AppState.currentOperatorId ?? 'Sin usuario',
      action: 'Pantalla de inicio cargada'
    );
  }

  void _navigateToPayment() {
    WebSocketService.sendScreenUpdate('home', 
      user: AppState.currentOperatorId ?? 'Sin usuario',
      action: 'Navegando a pantalla de pago'
    );
    context.push('/placa');
  }

  void _navigateToCancel() {
    WebSocketService.sendScreenUpdate('home', 
      user: AppState.currentOperatorId ?? 'Sin usuario',
      action: 'Navegando a pantalla de anulación'
    );
    context.push('/anular');
  }

  void _showLanguageModal() {
    AppRouter.showLanguageModal(context);
  }

  void _navigateToAccessibility() {
    context.push('/accesibilidad');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: AppState.accessibilityStream,
      builder: (context, snapshot) {
        return StreamBuilder<String>(
          stream: AppState.languageStream,
          builder: (context, languageSnapshot) {
            return _buildContent();
          },
        );
      },
    );
  }

  // Función para obtener la bandera del idioma actual
  String _getCurrentLanguageFlag() {
    switch (AppState.currentLanguage) {
      case 'es-ES':
        return '🇪🇸';
      case 'en':
        return '🇬🇧';
      case 'ca-ES':
        return '🏴'; // Catalán
      case 'gl-ES':
        return '🏴'; // Gallego
      case 'eu-ES':
        return '🏴'; // Euskera
      case 'fr-FR':
        return '🇫🇷';
      case 'de-DE':
        return '🇩🇪';
      case 'it-IT':
        return '🇮🇹';
      case 'pt-PT':
        return '🇵🇹';
      default:
        return '🇪🇸'; // Por defecto español
    }
  }

  Widget _buildContent() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade100,
              Colors.grey.shade200,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 48, // 24*2 padding
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo optimizado
                  _buildOptimizedLogo(),
                  const SizedBox(height: 40),
                  
                  // Título optimizado
                  _buildOptimizedTitle(),
                  const SizedBox(height: 16),
                  
                  // Subtítulo optimizado
                  _buildOptimizedSubtitle(),
                  const SizedBox(height: 60),
                  
                  // Botones principales optimizados
                  _buildOptimizedMainButtons(),
                  const SizedBox(height: 40),
                  
                  // Botones secundarios optimizados
                  _buildOptimizedSecondaryButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144),
            const Color(0xFFE62144).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_parking,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildOptimizedTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144),
            const Color(0xFFE62144).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        AppStrings.t('home.title'),
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 3.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptimizedSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE62144).withOpacity(0.9),
            const Color(0xFFE62144).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE62144).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        AppStrings.t('home.subtitle'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptimizedMainButtons() {
    return Column(
      children: [
        // Botón Pagar
        _buildOptimizedMainButton(
          title: AppStrings.t('home.pay'),
          subtitle: AppStrings.t('home.pay.subtitle'),
          icon: Icons.payment,
          onTap: _navigateToPayment,
        ),
        const SizedBox(height: 24),
        
        // Botón Anular
        _buildOptimizedMainButton(
          title: AppStrings.t('home.cancel'),
          subtitle: AppStrings.t('home.cancel.subtitle'),
          icon: Icons.cancel,
          onTap: _navigateToCancel,
        ),
      ],
    );
  }

  Widget _buildOptimizedMainButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE62144).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0xFFE62144).withOpacity(0.1),
          highlightColor: const Color(0xFFE62144).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icono
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE62144),
                        const Color(0xFFE62144).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE62144).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFE62144),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: const Color(0xFFE62144).withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFFE62144).withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedSecondaryButtons() {
    return Row(
      children: [
        // Botón Idioma
        Expanded(
          child: _buildOptimizedSecondaryButton(
            title: AppStrings.t('home.language'),
            icon: _getCurrentLanguageFlag(),
            onTap: _showLanguageModal,
          ),
        ),
        const SizedBox(width: 16),
        
        // Botón Accesibilidad
        Expanded(
          child: _buildOptimizedSecondaryButton(
            title: AppStrings.t('home.accessibility'),
            icon: '♿',
            onTap: _navigateToAccessibility,
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizedSecondaryButton({
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 137, // 110 * 1.25 = 137.5 ≈ 137
      height: 137, // 110 * 1.25 = 137.5 ≈ 137
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(68), // 137 / 2 = 68.5 ≈ 68
          splashColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.05),
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(15.0), // 12 * 1.25 = 15
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 40), // 32 * 1.25 = 40
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5), // 4 * 1.25 = 5
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14, // 11 * 1.25 = 13.75 ≈ 14
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
