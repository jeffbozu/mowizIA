import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../widgets/top_bar.dart';
import '../services/centralized_websocket_service.dart';
import '../services/dynamic_translations_service.dart';

class ExtendScreen extends StatefulWidget {
  const ExtendScreen({super.key});

  @override
  State<ExtendScreen> createState() => _ExtendScreenState();
}

class _ExtendScreenState extends State<ExtendScreen> {
  final TextEditingController _plateController = TextEditingController();
  ParkingSession? _currentSession;
  int _extraMinutes = 0;
  bool _isSearching = false;
  bool _hasSearched = false; // Para controlar si ya se ha buscado

  @override
  void initState() {
    super.initState();
    // Refrescar sesiones automáticamente al cargar la pantalla
    _refreshSessionsFromBackend();
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  // Método para refrescar automáticamente desde el backend
  void _refreshSessionsFromBackend() async {
    try {
      print('🔄 Refrescando sesiones desde el backend...');
      CentralizedWebSocketService.sendMessage({
        'type': 'get_data',
      });
      
      // Esperar un poco para que llegue la respuesta
      await Future.delayed(const Duration(milliseconds: 1000));
      
      print('✅ Sesiones refrescadas. Total: ${AppState.activeSessions.length}');
      AppState.activeSessions.forEach((key, value) {
        print('  - Matrícula: $key, Zona: ${value.zoneId}, Inicio: ${value.start}');
      });
    } catch (e) {
      print('❌ Error refrescando sesiones: $e');
    }
  }

  // Calcular minutos extra máximos usando datos del backend
  int _calculateMaxExtraMinutes(Zone zone, int sessionDuration) {
    // Usar maxDuration del modelo Zone (en minutos)
    final maxTotalMinutes = zone.maxDuration;
    
    // sessionDuration es el tiempo total de la sesión actual
    // Calcular cuánto tiempo se puede extender sin exceder el máximo
    final maxExtraMinutes = maxTotalMinutes - sessionDuration;
    
    // No permitir extensión si ya se alcanzó el máximo
    if (maxExtraMinutes <= 0) {
      return 0;
    }
    
    return maxExtraMinutes;
  }

  // Calcular precio usando datos del backend
  double _calculatePrice(double pricePerHour, int minutes) {
    // Calcular precio exacto
    final exactPrice = pricePerHour * (minutes / 60);
    // Redondear a 2 decimales
    return double.parse(exactPrice.toStringAsFixed(2));
  }

  void _searchSession() async {
    final plate = _plateController.text.trim().toUpperCase();
    
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t('extend.enter_plate')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
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
      _hasSearched = true; // Marcar que ya se ha buscado
    });

    // Debug: Mostrar todas las sesiones activas
    print('🔍 Buscando sesión para matrícula: $plate');
    print('📊 Sesiones activas totales: ${AppState.activeSessions.length}');
    AppState.activeSessions.forEach((key, value) {
      print('  - Matrícula: $key, Zona: ${value.zoneId}, Inicio: ${value.start}');
    });

    // Buscar SOLO en el backend - no usar datos locales
    ParkingSession? session;
    try {
      print('🔍 Buscando sesión en el backend...');
      
      // Solicitar datos actualizados del backend
      CentralizedWebSocketService.sendMessage({
        'type': 'get_data',
      });
      
      // Esperar un poco para que llegue la respuesta
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Buscar en el estado actualizado (que viene del backend)
      session = AppState.activeSessions[plate];
      
      // Si aún no se encuentra, hacer búsqueda específica en el backend
      if (session == null) {
        print('🔍 Sesión no encontrada, haciendo búsqueda específica en el backend...');
        // Buscar sesión usando Edge Functions
        final result = await CentralizedWebSocketService.searchSession(plate);
        if (result != null && result['success'] == true && result['session'] != null) {
          final foundSession = ParkingSession.fromJson(result['session']);
          AppState.activeSessions[plate] = foundSession;
          session = foundSession;
          print('✅ Sesión encontrada con Edge Functions');
        } else {
          print('❌ Error buscando sesión con Edge Functions: ${result?['error'] ?? 'Error desconocido'}');
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
        session = AppState.activeSessions[plate];
      }
    } catch (e) {
      print('❌ Error consultando backend: $e');
    }
    
    print('✅ Sesión encontrada: ${session != null ? "SÍ" : "NO"}');
    if (session != null) {
      print('  - Matrícula: ${session.plate}');
      print('  - Zona: ${session.zoneId}');
      print('  - Inicio: ${session.start}');
      print('  - Fin: ${session.end}');
      print('  - Precio: ${session.totalPrice}€');
    }
    
    setState(() {
      _currentSession = session;
      _isSearching = false;
      if (session != null) {
        _extraMinutes = 0;
      }
    });
    
    if (session != null) {
      // Calcular minutos extra máximos usando datos del backend
      final zone = AppState.zones[session.zoneId];
      final sessionDuration = session.end.difference(session.start).inMinutes;
      final maxExtra = zone != null ? _calculateMaxExtraMinutes(zone, sessionDuration) : 0;
      print('⏰ Minutos extra máximos: $maxExtra');
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DynamicTranslationsService.instance.t('extend.session_found', defaultValue: 'Sesión encontrada')),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      // Mostrar mensaje de no encontrado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DynamicTranslationsService.instance.t('extend.no_session', defaultValue: 'No se encontró sesión activa')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _selectExtraTime(int minutes) {
    if (_currentSession == null) return;
    
    final zone = AppState.zones[_currentSession!.zoneId];
    if (zone == null) return;
    
    // Calcular tiempo total de la sesión actual (desde inicio hasta fin)
    final sessionDuration = _currentSession!.end.difference(_currentSession!.start).inMinutes;
    final maxTotalMinutes = zone.maxDuration;
    
    // Validar que no exceda el máximo total
    if (minutes > maxTotalMinutes - sessionDuration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${DynamicTranslationsService.instance.t('extend.cannot_extend_more', defaultValue: 'No se puede extender más. Máximo de zona')}: ${(zone.maxDuration / 60).toStringAsFixed(1)}h. ${DynamicTranslationsService.instance.t('extend.remaining', defaultValue: 'Quedan')}: ${maxTotalMinutes - sessionDuration} min'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    setState(() {
      _extraMinutes = minutes;
    });
  }

  void _addMinutes(int minutes) {
    if (_currentSession == null) return;
    
    final zone = AppState.zones[_currentSession!.zoneId];
    if (zone == null) return;
    
    final sessionDuration = _currentSession!.end.difference(_currentSession!.start).inMinutes;
    final maxTotalMinutes = zone.maxDuration;
    final newExtra = _extraMinutes + minutes;
    
    // Validar que no exceda el máximo total
    if (newExtra > maxTotalMinutes - sessionDuration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${DynamicTranslationsService.instance.t('extend.cannot_extend_more', defaultValue: 'No se puede extender más. Máximo de zona')}: ${(zone.maxDuration / 60).toStringAsFixed(1)}h. ${DynamicTranslationsService.instance.t('extend.remaining', defaultValue: 'Quedan')}: ${maxTotalMinutes - sessionDuration} min'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    setState(() {
      _extraMinutes = newExtra;
    });
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
    
    final zone = AppState.zones[_currentSession!.zoneId];
    if (zone == null) return;
    
    // Validar que no se exceda el máximo de la zona
    final sessionDuration = _currentSession!.end.difference(_currentSession!.start).inMinutes;
    final maxExtra = _calculateMaxExtraMinutes(zone, sessionDuration);
    if (_extraMinutes > maxExtra) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${DynamicTranslationsService.instance.t('extend.cannot_extend_more', defaultValue: 'No se puede extender más. Máximo de zona')}: ${(zone.maxDuration / 60).toStringAsFixed(1)}h. ${DynamicTranslationsService.instance.t('extend.remaining', defaultValue: 'Quedan')}: $maxExtra min'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    final price = _calculatePrice(zone.pricePerHour, _extraMinutes);
    
    // Notificar al backend sobre la extensión de sesión usando Edge Functions
    final result = await CentralizedWebSocketService.extendSession(
      _currentSession!.plate,
      _extraMinutes,
      price,
    );
    if (result != null && result['success'] == true) {
      print('✅ Extensión de sesión procesada con Edge Functions');
    } else {
      print('❌ Error extendiendo sesión con Edge Functions: ${result?['error'] ?? 'Error desconocido'}');
    }
    
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
    final zone = AppState.zones[_currentSession!.zoneId];
    if (zone == null) return 0.0;
    return _calculatePrice(zone.pricePerHour, _extraMinutes);
  }

  int get _maxExtraMinutes {
    if (_currentSession == null) return 0;
    final zone = AppState.zones[_currentSession!.zoneId];
    if (zone == null) return 0;
    final sessionDuration = _currentSession!.end.difference(_currentSession!.start).inMinutes;
    return _calculateMaxExtraMinutes(zone, sessionDuration);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: AppState.configStream,
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
            title: DynamicTranslationsService.instance.t('extend.title', defaultValue: 'Extender Sesión'),
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
                      labelText: DynamicTranslationsService.instance.t('plate.title', defaultValue: 'Matrícula'),
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
                  // Botón de búsqueda
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
                        _isSearching ? DynamicTranslationsService.instance.t('common.loading', defaultValue: 'Cargando...') : DynamicTranslationsService.instance.t('extend.search', defaultValue: 'Buscar'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Contenido según el estado
                  if (_currentSession == null && !_isSearching && _hasSearched) ...[
                    // No hay sesión (solo después de buscar)
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
                            DynamicTranslationsService.instance.t('extend.no_session', defaultValue: 'No se encontró sesión activa'),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _backToZones,
                                  child: Text(DynamicTranslationsService.instance.t('extend.back_to_zones', defaultValue: 'Volver a Zonas')),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _startNew,
                                  child: Text(DynamicTranslationsService.instance.t('extend.start_new', defaultValue: 'Nuevo Estacionamiento')),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else if (_currentSession == null && !_isSearching && !_hasSearched) ...[
                    // Estado inicial - mostrar instrucciones
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            DynamicTranslationsService.instance.t('extend.enter_plate_to_search', defaultValue: 'Introduce la matrícula para buscar'),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            DynamicTranslationsService.instance.t('extend.search_instructions', defaultValue: 'Busca tu sesión activa para extender el tiempo'),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
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
                                  DynamicTranslationsService.instance.t('extend.title', defaultValue: 'Extender Sesión'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSessionInfo(DynamicTranslationsService.instance.t('ticket.plate', defaultValue: 'Matrícula'), _currentSession!.plate),
                                _buildSessionInfo(DynamicTranslationsService.instance.t('ticket.zone', defaultValue: 'Zona'), _currentSession!.zoneId),
                                _buildSessionInfo(
                                  DynamicTranslationsService.instance.t('extend.current_end', defaultValue: 'Fin Actual'),
                                  '${_currentEnd.hour.toString().padLeft(2, '0')}:${_currentEnd.minute.toString().padLeft(2, '0')}',
                                ),
                                _buildSessionInfo(
                                  DynamicTranslationsService.instance.t('extend.remaining', defaultValue: 'Tiempo Restante'),
                                  _formatMinutes(_currentSession!.remainingMinutes),
                                ),
                                _buildSessionInfo(
                                  DynamicTranslationsService.instance.t('extend.max_allowed', defaultValue: 'Máximo Permitido'),
                                  _getMaxAllowedTime(),
                                ),
                                _buildSessionInfo(
                                  DynamicTranslationsService.instance.t('extend.remaining_to_extend', defaultValue: 'Tiempo Restante para Extender'),
                                  _getRemainingTimeToExtend(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Selector de tiempo extra
                          Text(
                            DynamicTranslationsService.instance.t('extend.extra_time', defaultValue: 'Tiempo Extra'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          // Chips de tiempo
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _buildTimeChips(),
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
                                  DynamicTranslationsService.instance.t('extend.new_end', defaultValue: 'Nuevo Fin'),
                                  '${_newEnd.hour.toString().padLeft(2, '0')}:${_newEnd.minute.toString().padLeft(2, '0')}',
                                ),
                                _buildSessionInfo(
                                  DynamicTranslationsService.instance.t('extend.extra_amount', defaultValue: 'Cantidad Extra'),
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
                              child: Text(DynamicTranslationsService.instance.t('extend.go_pay', defaultValue: 'Ir a Pago')),
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

  List<Widget> _buildTimeChips() {
    final timeOptions = [15, 30, 60, 120, 180, 240]; // Opciones de tiempo en minutos
    final validOptions = timeOptions.where((minutes) => minutes <= _maxExtraMinutes).toList();
    
    return validOptions.map((minutes) => _buildTimeChip(minutes)).toList();
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

  String _getMaxAllowedTime() {
    if (_currentSession == null) return '';
    
    final zone = AppState.zones[_currentSession!.zoneId];
    if (zone == null) return '';
    
    final maxHours = zone.maxDuration / 60;
    return AppStrings.t('extend.max_allowed_hours', params: {
      'hours': maxHours.toStringAsFixed(1)
    });
  }

  String _getRemainingTimeToExtend() {
    if (_currentSession == null) return '';
    
    final zone = AppState.zones[_currentSession!.zoneId];
    if (zone == null) return '';
    
    final sessionDuration = _currentSession!.end.difference(_currentSession!.start).inMinutes;
    final remainingToExtend = zone.maxDuration - sessionDuration;
    
    print('🔍 DEBUG _getRemainingTimeToExtend:');
    print('  - Zona: ${_currentSession!.zoneId}');
    print('  - maxDuration: ${zone.maxDuration} min');
    print('  - sessionDuration: $sessionDuration min');
    print('  - remainingToExtend: $remainingToExtend min');
    
    if (remainingToExtend <= 0) {
      return '0 min (máximo alcanzado)';
    }
    
    return _formatMinutes(remainingToExtend.toInt());
  }
}