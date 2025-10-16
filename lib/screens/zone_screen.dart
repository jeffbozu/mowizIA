import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/top_bar.dart';
import '../widgets/progress_bar.dart';
import '../services/websocket_service.dart';
import '../services/voice_guide_service.dart';
import '../services/adaptive_ai_service.dart';
import '../services/simplified_mode_service.dart';
import '../services/dynamic_translations_service.dart';

// Función para convertir string de color a Color
Color _parseColor(String colorString) {
  try {
    return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
  } catch (e) {
    return const Color(0xFF2196F3); // Color por defecto
  }
}

class ZoneScreen extends StatefulWidget {
  const ZoneScreen({super.key});

  @override
  State<ZoneScreen> createState() => _ZoneScreenState();
}

class _ZoneScreenState extends State<ZoneScreen> {
  String? selectedZoneId;

  @override
  void initState() {
    super.initState();
    // Enviar datos de pantalla al dashboard
    WebSocketService.sendScreenUpdate('zone', 
      user: AppState.currentOperator?.username ?? 'Sin usuario',
      action: 'Seleccionando zona de estacionamiento'
    );
    
    // Registrar acción para IA adaptativa
    AdaptiveAIService.recordAction('zone_screen_visited');
    
    // Reproducir guía por voz si está habilitada
    _playVoiceGuide();
  }
  
  void _playVoiceGuide() {
    if (AppState.voiceGuideEnabled) {
      // Esperar un poco para que la pantalla se cargue completamente
      Future.delayed(const Duration(milliseconds: 500), () {
        VoiceGuideService.speak(DynamicTranslationsService.instance.t('voice.zone.title', defaultValue: 'Selecciona una zona'));
        Future.delayed(const Duration(seconds: 2), () {
          VoiceGuideService.speak(DynamicTranslationsService.instance.t('voice.zone.instruction', defaultValue: 'Toca la zona donde quieres estacionar'));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: AppState.accessibilityStream,
      builder: (context, snapshot) {
        // Obtener zonas de la empresa actual
        final zones = AppState.currentCompany != null 
            ? AppState.getZonesForCompany(AppState.currentCompany!.id)
            : <Zone>[];

        return _buildContent(zones);
      },
    );
  }

  Widget _buildContent(List<Zone> zones) {
    final uiConfig = SimplifiedModeService.getUIConfig();
    final isSimplified = SimplifiedModeService.isActive;
    
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: DynamicTranslationsService.instance.t('zone.title', defaultValue: 'Seleccionar Zona'),
            showBackButton: true,
            onBack: () => context.go('/home'),
          ),
          // Barra de progreso interactiva
          ProgressBar(
            currentStep: 0,
            onStepTap: (step) {
              switch (step) {
                case 0:
                  // Ya estamos en zona
                  break;
                case 1:
                  context.push('/matricula');
                  break;
                case 2:
                  context.push('/tiempo');
                  break;
                case 3:
                  context.push('/pago');
                  break;
                case 4:
                  context.push('/ticket');
                  break;
              }
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  
                  // Instrucciones simplificadas
                  if (isSimplified) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        SimplifiedModeService.getSimplifiedInstructions('zone'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Botón Extender Sesión (ocultar en modo simplificado)
                  if (!isSimplified) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/extender'),
                        icon: const Icon(Icons.schedule, size: 28),
                        label: Text(
                          DynamicTranslationsService.instance.t('zone.extend', defaultValue: 'Extender Sesión'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Grid de zonas
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSimplified ? 1 : 2,
                        childAspectRatio: isSimplified ? 3.5 : 1.8, // Un poco más grandes
                        crossAxisSpacing: uiConfig.spacing,
                        mainAxisSpacing: uiConfig.spacing,
                      ),
                      itemCount: zones.length,
                      itemBuilder: (context, index) {
                        final zone = zones[index];
                        final isSelected = selectedZoneId == zone.id;
                        return _buildZoneCard(zone, isSelected, uiConfig);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón Siguiente
                  SizedBox(
                    width: double.infinity,
                    height: uiConfig.buttonSize,
                    child: FilledButton(
                      onPressed: selectedZoneId != null ? _next : null,
                      child: Text(
                        DynamicTranslationsService.instance.t('zone.next', defaultValue: 'Continuar'),
                        style: TextStyle(
                          fontSize: uiConfig.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(Zone zone, bool isSelected, SimplifiedUIConfig uiConfig) {
    final zoneColor = _parseColor(zone.color);
    final isSimplified = SimplifiedModeService.isActive;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedZoneId = zone.id;
        });
        AppState.selectedZoneId = zone.id;
        
        // Registrar acción para IA adaptativa
        AdaptiveAIService.recordAction('zone_selected');
        
        // Reproducir guía por voz de selección
        if (AppState.voiceGuideEnabled) {
          VoiceGuideService.speak('${DynamicTranslationsService.instance.t('voice.zone.selected', defaultValue: 'Zona seleccionada')} ${zone.name}');
        }
        
        // Enviar datos de pantalla al dashboard
        WebSocketService.sendScreenUpdate('zone', 
          user: AppState.currentOperator?.username ?? 'Sin usuario',
          action: 'Zona seleccionada: ${zone.name}',
          selectedZone: zone.id,
          zone: zone.name
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    zoneColor.withOpacity(0.15),
                    zoneColor.withOpacity(0.05),
                  ]
                : [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.85),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? zoneColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? zoneColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: isSelected 
                  ? zoneColor.withOpacity(0.1)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 32 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isSimplified ? _buildSimplifiedZoneCard(zone, isSelected, zoneColor, uiConfig) : _buildNormalZoneCard(zone, isSelected, zoneColor),
      ),
    );
  }
  
  Widget _buildNormalZoneCard(Zone zone, bool isSelected, Color zoneColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Color de zona
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                zoneColor,
                zoneColor.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: zoneColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.local_parking,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        // Nombre de zona
        Text(
          zone.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? zoneColor
                : Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        // Precio por hora
        Text(
          '${zone.pricePerHour.toStringAsFixed(2)} ${AppStrings.t('zone.price_per_hour')}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected 
                ? zoneColor
                : const Color(0xFFE62144), // Rojo corporativo
          ),
        ),
        const SizedBox(height: 4),
        // Máximo de horas
        Text(
          AppStrings.t('zone.max_hours', params: {'hours': (zone.maxDuration / 60).toString()}),
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSimplifiedZoneCard(Zone zone, bool isSelected, Color zoneColor, SimplifiedUIConfig uiConfig) {
    return Row(
      children: [
        // Color de zona (más grande en modo simplificado)
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: zoneColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_parking,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        // Información de zona
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nombre de zona (más grande)
              Text(
                zone.name,
                style: TextStyle(
                  fontSize: uiConfig.fontSize,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? zoneColor
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Precio por hora (más grande)
              Text(
                '${zone.pricePerHour.toStringAsFixed(2)} ${DynamicTranslationsService.instance.t('zone.price_per_hour', defaultValue: '€/hora')}',
                style: TextStyle(
                  fontSize: uiConfig.fontSize * 0.8,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              // Máximo de horas
              Text(
                DynamicTranslationsService.instance.t('zone.max_hours', defaultValue: 'Máximo ${(zone.maxDuration / 60).toString()} horas'),
                style: TextStyle(
                  fontSize: uiConfig.fontSize * 0.6,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // Indicador de selección
        if (isSelected)
          Icon(
            Icons.check_circle,
            color: zoneColor,
            size: 32,
          ),
      ],
    );
  }

  void _next() {
    if (selectedZoneId != null) {
      // Reproducir guía por voz de confirmación
      if (AppState.voiceGuideEnabled) {
        VoiceGuideService.speak(DynamicTranslationsService.instance.t('voice.zone.selected', defaultValue: 'Zona seleccionada'));
      }
      context.push('/matricula');
    }
  }
}