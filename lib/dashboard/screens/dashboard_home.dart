import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models.dart';
import '../../services/websocket_service.dart';
import '../../i18n/strings.dart';
import 'kiosco_monitor_screen.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  String? selectedKioscoId;
  final Map<String, KioscoStatus> _kioscos = {};

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    // Conectar como dashboard
    WebSocketService.connectDashboard('dashboard-main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MEYPARK Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: Icon(Icons.settings),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: Row(
        children: [
          // Panel lateral con lista de kioscos
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // Header del panel
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
                        Icons.dashboard,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kioscos Conectados',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de kioscos
                Expanded(
                  child: StreamBuilder<Map<String, dynamic>>(
                    stream: WebSocketService.messageStream,
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: _kioscos.length,
                        itemBuilder: (context, index) {
                          final kioscoId = _kioscos.keys.elementAt(index);
                          final status = _kioscos[kioscoId]!;
                          return _buildKioscoCard(kioscoId, status);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Panel principal
          Expanded(
            child: selectedKioscoId != null
                ? KioscoMonitorScreen(kioscoId: selectedKioscoId!)
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildKioscoCard(String kioscoId, KioscoStatus status) {
    final isSelected = selectedKioscoId == kioscoId;
    
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        selected: isSelected,
        leading: CircleAvatar(
          backgroundColor: status.isOnline 
              ? Colors.green 
              : Colors.red,
          child: Icon(
            status.isOnline ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text('Kiosco $kioscoId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${status.isOnline ? "Online" : "Offline"}'),
            Text('Pantalla: ${status.currentScreen}'),
            Text('Última actualización: ${_formatTime(status.lastUpdate)}'),
          ],
        ),
        onTap: () {
          setState(() {
            selectedKioscoId = kioscoId;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: 16),
          Text(
            'Selecciona un kiosco',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Elige un kiosco del panel lateral para monitorearlo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configuración del Dashboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.web),
              title: Text('Servidor WebSocket'),
              subtitle: Text('ws://localhost:8080'),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Reconectar'),
              onTap: () {
                Navigator.pop(context);
                _connectToWebSocket();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
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

// Modelo para el estado del kiosco
class KioscoStatus {
  final String kioscoId;
  final bool isOnline;
  final String currentScreen;
  final DateTime lastUpdate;
  final Map<String, dynamic> technicalStatus;

  KioscoStatus({
    required this.kioscoId,
    required this.isOnline,
    required this.currentScreen,
    required this.lastUpdate,
    required this.technicalStatus,
  });

  factory KioscoStatus.fromJson(Map<String, dynamic> json) {
    return KioscoStatus(
      kioscoId: json['kioscoId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      currentScreen: json['currentScreen'] ?? 'unknown',
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
      technicalStatus: json['technicalStatus'] ?? {},
    );
  }
}
