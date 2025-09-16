import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../widgets/top_bar.dart';
import '../services/websocket_service.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  int _selectedMinutes = 60; // 1 hora por defecto
  late Zone _selectedZone;

  @override
  void initState() {
    super.initState();
    final zoneId = AppState.selectedZoneId;
    _selectedZone = MockData.getZoneById(zoneId!)!;
  }

  void _selectTime(int minutes) {
    setState(() {
      _selectedMinutes = minutes;
    });
  }

  void _addMinutes(int minutes) {
    final newMinutes = _selectedMinutes + minutes;
    final maxMinutes = _selectedZone.maxHours * 60;
    
    if (newMinutes <= maxMinutes) {
      setState(() {
        _selectedMinutes = newMinutes;
      });
    }
  }

  void _subtractMinutes(int minutes) {
    final newMinutes = _selectedMinutes - minutes;
    if (newMinutes >= 15) { // Mínimo 15 minutos
      setState(() {
        _selectedMinutes = newMinutes;
      });
    }
  }

  void _pay() {
    final price = MockData.calculatePrice(_selectedZone.pricePerHour, _selectedMinutes);
    context.push('/pago', extra: {
      'extend': false,
      'matricula': '1234ABC', // TODO: Obtener de la sesión actual
      'zonaId': _selectedZone.id,
      'minutos': _selectedMinutes,
      'precio': price,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: AppState.accessibilityStream,
      builder: (context, snapshot) {
        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    final timeOptions = [15, 30, 60, 120, 180, 240]; // 15m, 30m, 1h, 2h, 3h, 4h
    final maxMinutes = _selectedZone.maxHours * 60;
    final availableOptions = timeOptions.where((minutes) => minutes <= maxMinutes).toList();

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: AppStrings.t('time.title'),
            showBackButton: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Información de la zona seleccionada
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _parseColor(_selectedZone.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _parseColor(_selectedZone.color),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(_selectedZone.color),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_parking,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedZone.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_selectedZone.pricePerHour.toStringAsFixed(2)} ${AppStrings.t('zone.price_per_hour')}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tiempo seleccionado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatTime(_selectedMinutes),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.t('time.until') + ' ${_formatEndTime()}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Opciones de tiempo rápidas
                  Text(
                    AppStrings.t('time.quick_select'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableOptions.map((minutes) {
                      final isSelected = _selectedMinutes == minutes;
                      return GestureDetector(
                        onTap: () => _selectTime(minutes),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            _formatTime(minutes),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  // Controles de tiempo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _subtractMinutes(15),
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      // Texto del tiempo actual
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          _formatTime(_selectedMinutes),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () => _addMinutes(15),
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Precio total
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.t('time.total'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${MockData.calculatePrice(_selectedZone.pricePerHour, _selectedMinutes).toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón de pago
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: FilledButton(
                      onPressed: _pay,
                      child: Text(
                        AppStrings.t('time.pay'),
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

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  String _formatEndTime() {
    final endTime = DateTime.now().add(Duration(minutes: _selectedMinutes));
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }
}