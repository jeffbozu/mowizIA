import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/top_bar.dart';
import '../i18n/strings.dart';
import '../data/mock_data.dart';
import '../data/app_state.dart';

class PlateScreen extends StatefulWidget {
  const PlateScreen({super.key});

  @override
  State<PlateScreen> createState() => _PlateScreenState();
}

class _PlateScreenState extends State<PlateScreen> {
  final TextEditingController _plateController = TextEditingController();
  bool _isValidPlate = false;

  @override
  void initState() {
    super.initState();
    // Verificar que hay una zona seleccionada
    if (AppState.selectedZone == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/zona');
      });
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _validatePlate() {
    final plate = _plateController.text.trim().toUpperCase();
    final isValid = MockData.isValidPlate(plate);
    setState(() {
      _isValidPlate = isValid;
    });
  }

  void _clearPlate() {
    setState(() {
      _plateController.clear();
      _isValidPlate = false;
    });
  }

  void _goToTime() {
    if (_isValidPlate) {
      context.push('/tiempo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final zone = AppState.selectedZone;
    
    if (zone == null) {
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
              AppStrings.t('plate.title'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Zona seleccionada: ${zone.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Campo de matrícula
            TextField(
              controller: _plateController,
              onChanged: (value) => _validatePlate(),
              decoration: InputDecoration(
                labelText: AppStrings.t('plate.hint'),
                prefixIcon: const Icon(Icons.directions_car),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _clearPlate,
                      icon: const Icon(Icons.clear),
                    ),
                    if (_isValidPlate)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
                helperText: 'Formato: 4 números + 3 letras (ej: 1234ABC)',
                errorText: _plateController.text.isNotEmpty && !_isValidPlate
                    ? 'Formato inválido'
                    : null,
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => _goToTime(),
            ),

            const SizedBox(height: 32),

            // Información de la zona
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(MockData.getZoneColor(zone.color)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getZoneIcon(zone.color),
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${zone.pricePerHour.toStringAsFixed(2)} €/h',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(MockData.getZoneColor(zone.color)),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Máximo ${zone.maxHours} horas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(AppStrings.t('plate.back')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isValidPlate ? _goToTime : null,
                    child: Text(AppStrings.t('plate.next')),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            
            Text(
              'Hello MEYPARK - Etapa 6',
              style: const TextStyle(fontSize: 18),
            ),
          ],
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
