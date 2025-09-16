import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../widgets/top_bar.dart';

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
    final plate = _plateController.text.toUpperCase();
    
    if (!MockData.validatePlate(plate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t('plate.invalid_format')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simular búsqueda
    await Future.delayed(const Duration(seconds: 1));

    final session = MockData.getSessionByPlate(plate);
    
    setState(() {
      _currentSession = session;
      _isSearching = false;
      if (session != null) {
        _extraMinutes = 0;
      }
    });
  }

  void _selectExtraTime(int minutes) {
    if (_currentSession == null) return;
    
    final maxExtra = MockData.getMaxExtraMinutes(
      _currentSession!.zoneId,
      _currentSession!.consumedMinutes,
    );
    
    final newExtra = _extraMinutes + minutes;
    if (newExtra <= maxExtra) {
      setState(() {
        _extraMinutes = newExtra;
      });
    }
  }

  void _addMinutes(int minutes) {
    if (_currentSession == null) return;
    
    final maxExtra = MockData.getMaxExtraMinutes(
      _currentSession!.zoneId,
      _currentSession!.consumedMinutes,
    );
    
    final newExtra = _extraMinutes + minutes;
    if (newExtra <= maxExtra) {
      setState(() {
        _extraMinutes = newExtra;
      });
    }
  }

  void _subtractMinutes(int minutes) {
    final newExtra = _extraMinutes - minutes;
    if (newExtra >= 0) {
      setState(() {
        _extraMinutes = newExtra;
      });
    }
  }

  void _goToPayment() {
    if (_currentSession == null) return;
    
    final zone = MockData.getZoneById(_currentSession!.zoneId);
    final price = MockData.calculatePrice(zone!.pricePerHour, _extraMinutes);
    
    context.push('/pago', extra: {
      'extend': true,
      'minutosExtra': _extraMinutes,
      'precioExtra': price,
      'zonaId': _currentSession!.zoneId,
      'matricula': _currentSession!.plate,
    });
  }

  void _backToZones() {
    context.go('/zona');
  }

  void _startNew() {
    context.go('/zona');
  }

  DateTime get _currentEnd {
    return _currentSession?.end ?? DateTime.now();
  }

  DateTime get _newEnd {
    return _currentEnd.add(Duration(minutes: _extraMinutes));
  }

  double get _extraPrice {
    if (_currentSession == null) return 0.0;
    final zone = MockData.getZoneById(_currentSession!.zoneId);
    return MockData.calculatePrice(zone!.pricePerHour, _extraMinutes);
  }

  int get _maxExtraMinutes {
    if (_currentSession == null) return 0;
    return MockData.getMaxExtraMinutes(
      _currentSession!.zoneId,
      _currentSession!.consumedMinutes,
    );
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
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: AppStrings.t('extend.title'),
            showBackButton: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Campo de búsqueda
                  TextField(
                    controller: _plateController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      labelText: AppStrings.t('plate.title'),
                      hintText: '1234ABC',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                      suffixIcon: _plateController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () => _plateController.clear(),
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      // Convertir a mayúsculas automáticamente
                      if (value != value.toUpperCase()) {
                        _plateController.value = _plateController.value.copyWith(
                          text: value.toUpperCase(),
                          selection: TextSelection.collapsed(offset: value.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // Botón buscar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _isSearching ? null : _searchSession,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _isSearching ? AppStrings.t('common.loading') : AppStrings.t('extend.search'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Contenido según el estado
                  if (_currentSession == null && !_isSearching) ...[
                    // No hay sesión
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppStrings.t('extend.no_session'),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _backToZones,
                                  child: Text(AppStrings.t('extend.back_to_zones')),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _startNew,
                                  child: Text(AppStrings.t('extend.start_new')),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else if (_currentSession != null) ...[
                    // Sesión encontrada
                    Expanded(
                      child: Column(
                        children: [
                          // Información de sesión actual
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.t('extend.title'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSessionInfo(AppStrings.t('ticket.plate'), _currentSession!.plate),
                                _buildSessionInfo(AppStrings.t('ticket.zone'), _currentSession!.zoneId),
                                _buildSessionInfo(
                                  AppStrings.t('extend.current_end'),
                                  '${_currentEnd.hour.toString().padLeft(2, '0')}:${_currentEnd.minute.toString().padLeft(2, '0')}',
                                ),
                                _buildSessionInfo(
                                  AppStrings.t('extend.remaining'),
                                  _formatMinutes(_currentSession!.remainingMinutes),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Selector de tiempo extra
                          Text(
                            AppStrings.t('extend.extra_time'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          // Chips de tiempo
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildTimeChip(15),
                              _buildTimeChip(30),
                              _buildTimeChip(60),
                              _buildTimeChip(120),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Controles +/- 5 minutos
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: _extraMinutes > 0 ? () => _subtractMinutes(5) : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                iconSize: 32,
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatMinutes(_extraMinutes),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              IconButton(
                                onPressed: _extraMinutes < _maxExtraMinutes ? () => _addMinutes(5) : null,
                                icon: const Icon(Icons.add_circle_outline),
                                iconSize: 32,
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Información de extensión
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildSessionInfo(
                                  AppStrings.t('extend.new_end'),
                                  '${_newEnd.hour.toString().padLeft(2, '0')}:${_newEnd.minute.toString().padLeft(2, '0')}',
                                ),
                                _buildSessionInfo(
                                  AppStrings.t('extend.extra_amount'),
                                  '${_extraPrice.toStringAsFixed(2)} €',
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Botón Ir a Pago
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _extraMinutes > 0 ? _goToPayment : null,
                              child: Text(AppStrings.t('extend.go_pay')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(int minutes) {
    final isSelected = _extraMinutes == minutes;
    final canSelect = minutes <= _maxExtraMinutes;
    
    return FilterChip(
      label: Text(_formatMinutes(minutes)),
      selected: isSelected,
      onSelected: canSelect ? (selected) {
        if (selected) {
          _selectExtraTime(minutes);
        }
      } : null,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  String _formatMinutes(int minutes) {
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
}