import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import '../../data/models.dart';
import '../../services/websocket_service.dart';
import '../../i18n/strings.dart';

class KioscoMonitorScreen extends StatefulWidget {
  final String kioscoId;

  const KioscoMonitorScreen({
    super.key,
    required this.kioscoId,
  });

  @override
  State<KioscoMonitorScreen> createState() => _KioscoMonitorScreenState();
}

class _KioscoMonitorScreenState extends State<KioscoMonitorScreen> {
  KioscoStatus? _kioscoStatus;
  bool _isControlling = false;

  @override
  void initState() {
    super.initState();
    _requestKioscoStatus();
  }

  void _requestKioscoStatus() {
    WebSocketService.sendMessage({
      'type': 'request_status',
      'target': 'kiosco',
      'kioscoId': widget.kioscoId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header del kiosco
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.store,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Kiosco ${widget.kioscoId}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              // Estado de conexión
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _kioscoStatus?.isOnline == true ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _kioscoStatus?.isOnline == true ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Contenido principal
        Expanded(
          child: Row(
            children: [
              // Panel de pantalla en vivo
              Expanded(
                flex: 2,
                child: _buildScreenCapturePanel(),
              ),
              // Panel de estado técnico
              Expanded(
                flex: 1,
                child: _buildTechnicalStatusPanel(),
              ),
            ],
          ),
        ),
        // Panel de control remoto
        Container(
          height: 80,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              // Botón de control remoto
              ElevatedButton.icon(
                onPressed: _toggleControl,
                icon: Icon(_isControlling ? Icons.stop : Icons.play_arrow),
                label: Text(_isControlling ? 'Detener Control' : 'Control Remoto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isControlling ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              // Botón de captura de pantalla
              ElevatedButton.icon(
                onPressed: _requestScreenCapture,
                icon: Icon(Icons.screenshot),
                label: Text('Capturar Pantalla'),
              ),
              SizedBox(width: 16),
              // Botón de reinicio
              ElevatedButton.icon(
                onPressed: _restartKiosco,
                icon: Icon(Icons.restart_alt),
                label: Text('Reiniciar Kiosco'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreenCapturePanel() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          // Header de la pantalla
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.monitor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Pantalla en Vivo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  'Última actualización: ${_formatTime(_kioscoStatus?.lastUpdate ?? DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Área de captura de pantalla
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: _kioscoStatus?.screenCapture != null
                  ? Image.memory(
                      _kioscoStatus!.screenCapture!,
                      fit: BoxFit.contain,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.screenshot_monitor,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay captura disponible',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Presiona "Capturar Pantalla" para obtener una imagen',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalStatusPanel() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado Técnico',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Batería
            _buildStatusRow(
              icon: Icons.battery_charging_full,
              label: 'Batería',
              value: '${_kioscoStatus?.technicalStatus['batteryLevel'] ?? 0}%',
              status: _getBatteryStatus(),
            ),
            SizedBox(height: 12),
            // Impresora
            _buildStatusRow(
              icon: Icons.print,
              label: 'Impresora',
              value: _kioscoStatus?.technicalStatus['printerConnected'] == true 
                  ? 'Conectada' 
                  : 'Desconectada',
              status: _kioscoStatus?.technicalStatus['printerConnected'] == true 
                  ? Status.good 
                  : Status.error,
            ),
            SizedBox(height: 12),
            // Papel
            _buildStatusRow(
              icon: Icons.description,
              label: 'Papel',
              value: _kioscoStatus?.technicalStatus['printerHasPaper'] == true 
                  ? 'Disponible' 
                  : 'Sin papel',
              status: _kioscoStatus?.technicalStatus['printerHasPaper'] == true 
                  ? Status.good 
                  : Status.warning,
            ),
            SizedBox(height: 12),
            // Tinta
            _buildStatusRow(
              icon: Icons.color_lens,
              label: 'Tinta',
              value: _kioscoStatus?.technicalStatus['printerHasInk'] == true 
                  ? 'Disponible' 
                  : 'Sin tinta',
              status: _kioscoStatus?.technicalStatus['printerHasInk'] == true 
                  ? Status.good 
                  : Status.warning,
            ),
            SizedBox(height: 12),
            // Red
            _buildStatusRow(
              icon: Icons.wifi,
              label: 'Red',
              value: _kioscoStatus?.technicalStatus['networkConnected'] == true 
                  ? 'Conectada' 
                  : 'Desconectada',
              status: _kioscoStatus?.technicalStatus['networkConnected'] == true 
                  ? Status.good 
                  : Status.error,
            ),
            SizedBox(height: 12),
            // Pantalla actual
            _buildStatusRow(
              icon: Icons.screen_share,
              label: 'Pantalla',
              value: _kioscoStatus?.currentScreen ?? 'Desconocida',
              status: Status.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
    required Status status,
  }) {
    Color statusColor;
    switch (status) {
      case Status.good:
        statusColor = Colors.green;
        break;
      case Status.warning:
        statusColor = Colors.orange;
        break;
      case Status.error:
        statusColor = Colors.red;
        break;
      case Status.info:
        statusColor = Colors.blue;
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 20, color: statusColor),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Status _getBatteryStatus() {
    final batteryLevel = _kioscoStatus?.technicalStatus['batteryLevel'] ?? 0;
    if (batteryLevel > 50) return Status.good;
    if (batteryLevel > 20) return Status.warning;
    return Status.error;
  }

  void _toggleControl() {
    setState(() {
      _isControlling = !_isControlling;
    });
    
    WebSocketService.sendMessage({
      'type': _isControlling ? 'start_control' : 'stop_control',
      'target': 'kiosco',
      'kioscoId': widget.kioscoId,
    });
  }

  void _requestScreenCapture() {
    WebSocketService.sendMessage({
      'type': 'request_screen_capture',
      'target': 'kiosco',
      'kioscoId': widget.kioscoId,
    });
  }

  void _restartKiosco() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reiniciar Kiosco'),
        content: Text('¿Estás seguro de que quieres reiniciar el kiosco ${widget.kioscoId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              WebSocketService.sendMessage({
                'type': 'restart_kiosco',
                'target': 'kiosco',
                'kioscoId': widget.kioscoId,
              });
            },
            child: Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}

enum Status { good, warning, error, info }

// Modelo extendido para el estado del kiosco
class KioscoStatus {
  final String kioscoId;
  final bool isOnline;
  final String currentScreen;
  final DateTime lastUpdate;
  final Map<String, dynamic> technicalStatus;
  final Uint8List? screenCapture;

  KioscoStatus({
    required this.kioscoId,
    required this.isOnline,
    required this.currentScreen,
    required this.lastUpdate,
    required this.technicalStatus,
    this.screenCapture,
  });

  factory KioscoStatus.fromJson(Map<String, dynamic> json) {
    return KioscoStatus(
      kioscoId: json['kioscoId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      currentScreen: json['currentScreen'] ?? 'unknown',
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
      technicalStatus: json['technicalStatus'] ?? {},
      screenCapture: json['screenCapture'] != null 
          ? Uint8List.fromList(json['screenCapture'].cast<int>())
          : null,
    );
  }
}
