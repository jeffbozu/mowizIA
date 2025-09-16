import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/top_bar.dart';
import '../services/websocket_service.dart';

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
    return Scaffold(
      body: Column(
        children: [
          TopBar(title: AppStrings.t('zone.title')),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Información de la empresa
                  if (AppState.currentCompany != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.business,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppState.currentCompany!.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Botón Extender Sesión (destacado)
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/extender'),
                      icon: const Icon(Icons.schedule, size: 28),
                      label: Text(
                        AppStrings.t('zone.extend'),
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
                  // Grid de zonas
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: zones.length,
                      itemBuilder: (context, index) {
                        final zone = zones[index];
                        final isSelected = selectedZoneId == zone.id;
                        return _buildZoneCard(zone, isSelected);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón Siguiente
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: FilledButton(
                      onPressed: selectedZoneId != null ? _next : null,
                      child: Text(
                        AppStrings.t('zone.next'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildZoneCard(Zone zone, bool isSelected) {
    final zoneColor = _parseColor(zone.color);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedZoneId = zone.id;
        });
        AppState.selectedZoneId = zone.id;
        
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
          color: isSelected
              ? zoneColor.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? zoneColor : Theme.of(context).colorScheme.outline,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Color de zona
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: zoneColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_parking,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            // Nombre de zona
            Text(
              zone.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? zoneColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Precio por hora
            Text(
              '${zone.pricePerHour.toStringAsFixed(2)} ${AppStrings.t('zone.price_per_hour')}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            // Máximo de horas
            Text(
              AppStrings.t('zone.max_hours', params: {'hours': zone.maxHours.toString()}),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (selectedZoneId != null) {
      context.push('/matricula');
    }
  }
}