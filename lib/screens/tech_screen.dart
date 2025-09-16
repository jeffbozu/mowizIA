import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../widgets/top_bar.dart';

class TechScreen extends StatefulWidget {
  const TechScreen({super.key});

  @override
  State<TechScreen> createState() => _TechScreenState();
}

class _TechScreenState extends State<TechScreen> {
  // Estado mock del sistema
  bool _networkStatus = true;
  bool _printerStatus = true;
  bool _coinAcceptorStatus = true;
  bool _cardReaderStatus = true;
  double _temperature = 25.5;
  bool _doorStatus = false;

  // Contadores mock
  int _transactionsToday = 47;
  double _cashIncome = 156.80;
  double _cardIncome = 89.40;
  String _lastSync = '14:32';

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
            title: AppStrings.t('tech.title'),
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Estado del sistema
                  _buildSection(
                    AppStrings.t('tech.status'),
                    Icons.monitor,
                    [
                      _buildStatusItem(AppStrings.t('tech.network'), _networkStatus),
                      _buildStatusItem(AppStrings.t('tech.printer'), _printerStatus),
                      _buildStatusItem(AppStrings.t('tech.coin_acceptor'), _coinAcceptorStatus),
                      _buildStatusItem(AppStrings.t('tech.card_reader'), _cardReaderStatus),
                      _buildStatusItem('${AppStrings.t('tech.temperature')}: ${_temperature.toStringAsFixed(1)}°C', true),
                      _buildStatusItem('${AppStrings.t('tech.door')}: ${_doorStatus ? 'Abierta' : 'Cerrada'}', !_doorStatus),
                    ],
                    [
                      ElevatedButton.icon(
                        onPressed: _refreshStatus,
                        icon: const Icon(Icons.refresh),
                        label: Text(AppStrings.t('tech.refresh')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Diagnósticos
                  _buildSection(
                    AppStrings.t('tech.tests'),
                    Icons.build,
                    [],
                    [
                      ElevatedButton.icon(
                        onPressed: _testDisplay,
                        icon: const Icon(Icons.monitor),
                        label: Text(AppStrings.t('tech.test.display')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _testTouch,
                        icon: const Icon(Icons.touch_app),
                        label: Text(AppStrings.t('tech.test.touch')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _testPrinter,
                        icon: const Icon(Icons.print),
                        label: Text(AppStrings.t('tech.test.printer')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _testCoins,
                        icon: const Icon(Icons.monetization_on),
                        label: Text(AppStrings.t('tech.test.coins')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _testCard,
                        icon: const Icon(Icons.credit_card),
                        label: Text(AppStrings.t('tech.test.card')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Contadores
                  _buildSection(
                    AppStrings.t('tech.counters'),
                    Icons.analytics,
                    [
                      _buildCounterItem(AppStrings.t('tech.transactions_today'), _transactionsToday.toString()),
                      _buildCounterItem(AppStrings.t('tech.cash_income'), '${_cashIncome.toStringAsFixed(2)} €'),
                      _buildCounterItem(AppStrings.t('tech.card_income'), '${_cardIncome.toStringAsFixed(2)} €'),
                      _buildCounterItem(AppStrings.t('tech.last_sync'), _lastSync),
                    ],
                    [
                      ElevatedButton.icon(
                        onPressed: _resetDay,
                        icon: const Icon(Icons.restart_alt),
                        label: Text(AppStrings.t('tech.counter.reset_day')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Configuración
                  _buildSection(
                    AppStrings.t('tech.config'),
                    Icons.settings,
                    [
                      _buildConfigItem(AppStrings.t('tech.active_operator'), AppState.currentOperatorId ?? 'N/A'),
                      _buildConfigItem('Zonas cargadas', '5'),
                      _buildConfigItem('Tarifas cargadas', '5'),
                    ],
                    [
                      ElevatedButton.icon(
                        onPressed: _reloadConfig,
                        icon: const Icon(Icons.refresh),
                        label: Text(AppStrings.t('tech.reload_config')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Acciones
                  _buildSection(
                    AppStrings.t('tech.actions'),
                    Icons.power_settings_new,
                    [],
                    [
                      ElevatedButton.icon(
                        onPressed: _rebootApp,
                        icon: const Icon(Icons.restart_alt),
                        label: Text(AppStrings.t('tech.reboot_app')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close),
                        label: Text(AppStrings.t('tech.close')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> items, List<Widget> actions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...items,
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterItem(String label, String value) {
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

  Widget _buildConfigItem(String label, String value) {
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

  void _refreshStatus() {
    setState(() {
      _networkStatus = true;
      _printerStatus = true;
      _coinAcceptorStatus = true;
      _cardReaderStatus = true;
      _temperature = 25.5;
      _doorStatus = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.t('tech.refresh')),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _testDisplay() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando test de pantalla...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
    
    // Simular test de pantalla con cambio de colores
    await Future.delayed(const Duration(seconds: 1));
    
    // Cambiar color de fondo temporalmente
    setState(() {
      // Simular cambio de color
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Test de pantalla completado - OK'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _testTouch() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando test táctil...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Test táctil completado - OK'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _testPrinter() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imprimiendo ticket de prueba...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Test de impresora completado - OK'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _testCoins() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando test de monedas...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Test de monedas completado - OK'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _testCard() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando test de tarjeta...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Test de tarjeta completado - OK'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetDay() {
    setState(() {
      _transactionsToday = 0;
      _cashIncome = 0.0;
      _cardIncome = 0.0;
      _lastSync = DateTime.now().toString().substring(11, 16);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.t('tech.counter.reset_day')),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _reloadConfig() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.t('tech.reload_config')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rebootApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.t('tech.reboot_app')),
        content: Text('¿Está seguro de que desea reiniciar la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.t('common.no')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Mostrar mensaje de reinicio
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reiniciando aplicación...'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Reiniciar después de un delay
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  context.go('/login');
                }
              });
            },
            child: Text(AppStrings.t('common.yes')),
          ),
        ],
      ),
    );
  }
}