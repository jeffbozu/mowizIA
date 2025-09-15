import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/top_bar.dart';
import '../i18n/strings.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../data/app_state.dart';

class ExtendScreen extends StatefulWidget {
  const ExtendScreen({super.key});

  @override
  State<ExtendScreen> createState() => _ExtendScreenState();
}

class _ExtendScreenState extends State<ExtendScreen> {
  final TextEditingController _plateController = TextEditingController();
  Session? _currentSession;
  int _extraMinutes = 0;
  bool _isSearching = false;

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _searchSession() async {
    final plate = _plateController.text.trim().toUpperCase();
    
    if (!MockData.isValidPlate(plate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato de matrícula inválido. Use: 1234ABC'),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simular búsqueda
    await Future.delayed(const Duration(milliseconds: 500));

    final session = MockData.getSessionByPlate(plate);
    
    setState(() {
      _currentSession = session;
      _isSearching = false;
      _extraMinutes = 0;
    });
  }

  void _clearSearch() {
    setState(() {
      _plateController.clear();
      _currentSession = null;
      _extraMinutes = 0;
    });
  }

  void _adjustMinutes(int delta) {
    if (_currentSession == null) return;
    
    final zone = MockData.getZoneById(_currentSession!.zoneId);
    if (zone == null) return;
    
    final consumedMinutes = DateTime.now().difference(_currentSession!.start).inMinutes;
    final maxExtraMinutes = (zone.maxHours * 60) - consumedMinutes;
    
    setState(() {
      _extraMinutes = (_extraMinutes + delta).clamp(0, maxExtraMinutes);
    });
  }

  void _selectQuickTime(int minutes) {
    if (_currentSession == null) return;
    
    final zone = MockData.getZoneById(_currentSession!.zoneId);
    if (zone == null) return;
    
    final consumedMinutes = DateTime.now().difference(_currentSession!.start).inMinutes;
    final maxExtraMinutes = (zone.maxHours * 60) - consumedMinutes;
    
    setState(() {
      _extraMinutes = minutes.clamp(0, maxExtraMinutes);
    });
  }

  void _goToPayment() {
    if (_currentSession == null || _extraMinutes == 0) return;
    
    final zone = MockData.getZoneById(_currentSession!.zoneId);
    if (zone == null) return;
    
    final extraAmount = MockData.calculatePrice(zone.pricePerHour, _extraMinutes);
    final newEndTime = _currentSession!.end.add(Duration(minutes: _extraMinutes));
    
    final paymentContext = PaymentContext(
      isExtend: true,
      plate: _currentSession!.plate,
      zoneId: _currentSession!.zoneId,
      minutes: _extraMinutes,
      amount: extraAmount,
      endTime: newEndTime,
    );
    
    AppState.setPaymentContext(paymentContext);
    context.push('/pago');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.t('extend.title'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Campo de matrícula
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: AppStrings.t('plate.hint'),
                prefixIcon: const Icon(Icons.directions_car),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
                    IconButton(
                      onPressed: _isSearching ? null : _searchSession,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 24),

            // Resultado de búsqueda
            if (_currentSession != null) ...[
              _buildSessionInfo(),
            ] else if (_plateController.text.isNotEmpty && !_isSearching) ...[
              _buildNoSessionMessage(),
            ],

            const Spacer(),
            
            Text(
              'Hello MEYPARK - Etapa 5',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    final zone = MockData.getZoneById(_currentSession!.zoneId);
    if (zone == null) return const SizedBox.shrink();
    
    final consumedMinutes = DateTime.now().difference(_currentSession!.start).inMinutes;
    final maxExtraMinutes = (zone.maxHours * 60) - consumedMinutes;
    final extraAmount = MockData.calculatePrice(zone.pricePerHour, _extraMinutes);
    final newEndTime = _currentSession!.end.add(Duration(minutes: _extraMinutes));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sesión actual',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Matrícula', _currentSession!.plate),
                ),
                Expanded(
                  child: _buildInfoItem('Zona', zone.name),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Fin actual', _formatTime(_currentSession!.end)),
                ),
                Expanded(
                  child: _buildInfoItem('Tiempo restante', _formatDuration(DateTime.now().difference(_currentSession!.end).inMinutes)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Tiempo extra',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Chips de tiempo rápido
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTimeChip(15),
                _buildTimeChip(30),
                _buildTimeChip(60),
                _buildTimeChip(120),
              ],
            ),
            const SizedBox(height: 16),
            
            // Controles +/- 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _extraMinutes > 0 ? () => _adjustMinutes(-5) : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_extraMinutes min',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _extraMinutes < maxExtraMinutes ? () => _adjustMinutes(5) : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Máximo: $maxExtraMinutes min',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            
            // Resumen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nuevo fin:'),
                      Text(
                        _formatTime(newEndTime),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Importe adicional:'),
                      Text(
                        '${extraAmount.toStringAsFixed(2)} €',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.go('/zona'),
                    child: Text(AppStrings.t('extend.back_to_zones')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _extraMinutes > 0 ? _goToPayment : null,
                    child: Text(AppStrings.t('extend.go_pay')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSessionMessage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.t('extend.no_session'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/zona'),
                    child: Text(AppStrings.t('extend.back_to_zones')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/zona'),
                    child: Text(AppStrings.t('extend.start_new')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTimeChip(int minutes) {
    final isSelected = _extraMinutes == minutes;
    final zone = MockData.getZoneById(_currentSession!.zoneId);
    final consumedMinutes = DateTime.now().difference(_currentSession!.start).inMinutes;
    final maxExtraMinutes = zone != null ? (zone.maxHours * 60) - consumedMinutes : 0;
    final isEnabled = minutes <= maxExtraMinutes;
    
    return FilterChip(
      label: Text('+${minutes}m'),
      selected: isSelected,
      onSelected: isEnabled ? (selected) => _selectQuickTime(minutes) : null,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int minutes) {
    if (minutes < 0) return 'Expirado';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}
