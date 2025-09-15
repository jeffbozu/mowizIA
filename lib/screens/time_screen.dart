import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/top_bar.dart';
import '../i18n/strings.dart';
import '../data/mock_data.dart';
import '../data/app_state.dart';
import '../data/models.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  int _selectedMinutes = 60; // Por defecto 1 hora

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

  void _selectTime(int minutes) {
    setState(() {
      _selectedMinutes = minutes;
    });
  }

  void _adjustTime(int delta) {
    final zone = AppState.selectedZone;
    if (zone == null) return;
    
    final maxMinutes = zone.maxHours * 60;
    setState(() {
      _selectedMinutes = (_selectedMinutes + delta).clamp(15, maxMinutes);
    });
  }

  void _goToPayment() {
    final zone = AppState.selectedZone;
    if (zone == null) return;
    
    final totalAmount = MockData.calculatePrice(zone.pricePerHour, _selectedMinutes);
    final endTime = DateTime.now().add(Duration(minutes: _selectedMinutes));
    
    final paymentContext = PaymentContext(
      isExtend: false,
      plate: 'PLATE_PLACEHOLDER', // Se obtendrá de la pantalla anterior
      zoneId: zone.id,
      minutes: _selectedMinutes,
      amount: totalAmount,
      endTime: endTime,
    );
    
    AppState.setPaymentContext(paymentContext);
    context.push('/pago');
  }

  @override
  Widget build(BuildContext context) {
    final zone = AppState.selectedZone;
    
    if (zone == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalAmount = MockData.calculatePrice(zone.pricePerHour, _selectedMinutes);
    final endTime = DateTime.now().add(Duration(minutes: _selectedMinutes));

    return Scaffold(
      appBar: const TopBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t('time.title'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Zona: ${zone.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Chips de tiempo
            Text(
              'Seleccionar duración:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTimeChip(15),
                _buildTimeChip(30),
                _buildTimeChip(60),
                _buildTimeChip(120),
                _buildTimeChip(180),
                _buildTimeChip(240),
              ],
            ),
            
            const SizedBox(height: 24),

            // Controles +/- 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _selectedMinutes > 15 ? () => _adjustTime(-15) : null,
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    _formatDuration(_selectedMinutes),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _selectedMinutes < (zone.maxHours * 60) ? () => _adjustTime(15) : null,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Máximo: ${zone.maxHours} horas',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 32),

            // Resumen
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.t('time.until'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          _formatTime(endTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.t('time.total'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${totalAmount.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
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
                    onPressed: _goToPayment,
                    child: Text(AppStrings.t('time.pay')),
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

  Widget _buildTimeChip(int minutes) {
    final isSelected = _selectedMinutes == minutes;
    final isEnabled = minutes <= (AppState.selectedZone?.maxHours ?? 0) * 60;
    
    return FilterChip(
      label: Text(_formatDuration(minutes)),
      selected: isSelected,
      onSelected: isEnabled ? (selected) => _selectTime(minutes) : null,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
