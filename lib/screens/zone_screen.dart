import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/top_bar.dart';
import '../i18n/strings.dart';
import '../data/app_state.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../theme/tokens.dart';

class ZoneScreen extends StatefulWidget {
  const ZoneScreen({super.key});

  @override
  State<ZoneScreen> createState() => _ZoneScreenState();
}

class _ZoneScreenState extends State<ZoneScreen> {
  String? _selectedZoneId;

  @override
  void initState() {
    super.initState();
    // Verificar que hay un operador logueado
    if (AppState.currentOperator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }
  }

  void _selectZone(String zoneId) {
    setState(() {
      _selectedZoneId = zoneId;
    });
  }

  void _goToPlate() {
    if (_selectedZoneId != null) {
      final zone = MockData.getZoneById(_selectedZoneId!);
      if (zone != null) {
        AppState.setSelectedZone(zone);
        context.push('/matricula');
      }
    }
  }

  void _goToExtend() {
    context.push('/extender');
  }

  @override
  Widget build(BuildContext context) {
    final operator = AppState.currentOperator;
    
    if (operator == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const TopBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t('zone.title'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Operador: ${operator.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Botón Extender Sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _goToExtend,
                icon: const Icon(Icons.schedule),
                label: Text(AppStrings.t('zone.extend')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.zoneGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Grid de zonas
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: operator.zones.length,
                itemBuilder: (context, index) {
                  final zone = operator.zones[index];
                  final isSelected = _selectedZoneId == zone.id;
                  
                  return _buildZoneCard(zone, isSelected);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Botón Siguiente
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedZoneId != null ? _goToPlate : null,
                child: Text(AppStrings.t('zone.next')),
              ),
            ),

            const SizedBox(height: 16),
            
            Text(
              'Hello MEYPARK - Etapa 4',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(Zone zone, bool isSelected) {
    final zoneColor = Color(MockData.getZoneColor(zone.color));
    
    return Card(
      elevation: isSelected ? 8 : 4,
      child: InkWell(
        onTap: () => _selectZone(zone.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: zoneColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getZoneIcon(zone.color),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                zone.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${zone.pricePerHour.toStringAsFixed(2)} €/h',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: zoneColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Máx ${zone.maxHours}h',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getZoneIcon(String color) {
    switch (color) {
      case 'blue':
        return Icons.local_parking;
      case 'green':
        return Icons.eco;
      case 'orange':
        return Icons.home;
      default:
        return Icons.place;
    }
  }
}
