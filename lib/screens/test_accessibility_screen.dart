import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../widgets/top_bar.dart';
import '../services/adaptive_ai_service.dart';
import '../services/simplified_mode_service.dart';

/// Pantalla de prueba para verificar funcionalidades de accesibilidad
class TestAccessibilityScreen extends StatefulWidget {
  const TestAccessibilityScreen({super.key});

  @override
  State<TestAccessibilityScreen> createState() => _TestAccessibilityScreenState();
}

class _TestAccessibilityScreenState extends State<TestAccessibilityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Pruebas de Accesibilidad',
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado actual
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado Actual',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatusRow('IA Adaptativa', AppState.adaptiveAI),
                          _buildStatusRow('Modo Simplificado', AppState.simplifiedMode),
                          _buildStatusRow('Guía por Voz', AppState.voiceGuideEnabled),
                          _buildStatusRow('Modo Oscuro', AppState.darkMode),
                          _buildStatusRow('Alto Contraste', AppState.highContrast),
                          _buildStatusRow('Tamaño de Fuente', AppState.fontSize),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pruebas de IA Adaptativa
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pruebas de IA Adaptativa',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              AdaptiveAIService.recordAction('test_action_1');
                              _showSnackBar('Acción registrada: test_action_1');
                            },
                            child: Text('Registrar Acción 1'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              AdaptiveAIService.recordAction('test_action_2');
                              _showSnackBar('Acción registrada: test_action_2');
                            },
                            child: Text('Registrar Acción 2'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              AdaptiveAIService.recordAction('voice_guide_used');
                              _showSnackBar('Acción registrada: voice_guide_used');
                            },
                            child: Text('Simular Uso de Guía por Voz'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              AdaptiveAIService.recordAction('large_buttons_used');
                              _showSnackBar('Acción registrada: large_buttons_used');
                            },
                            child: Text('Simular Uso de Botones Grandes'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sugerencias:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ...AdaptiveAIService.getSuggestions().map((suggestion) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text('• $suggestion'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pruebas de Modo Simplificado
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pruebas de Modo Simplificado',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                AppState.simplifiedMode = !AppState.simplifiedMode;
                              });
                              SimplifiedModeService.setEnabled(AppState.simplifiedMode);
                              _showSnackBar('Modo Simplificado: ${AppState.simplifiedMode ? "Activado" : "Desactivado"}');
                            },
                            child: Text(AppState.simplifiedMode ? 'Desactivar Modo Simplificado' : 'Activar Modo Simplificado'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Configuración UI:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final uiConfig = SimplifiedModeService.getUIConfig();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tamaño de botón: ${uiConfig.buttonSize}px'),
                                  Text('Tamaño de fuente: ${uiConfig.fontSize}px'),
                                  Text('Espaciado: ${uiConfig.spacing}px'),
                                  Text('Mostrar opciones avanzadas: ${uiConfig.showAdvancedOptions}'),
                                  Text('Máximo opciones por pantalla: ${uiConfig.maxOptionsPerScreen}'),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Información de la IA
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de la IA',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AdaptiveAIService.getAIInfo(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Información del Modo Simplificado:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            SimplifiedModeService.getInfo(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botones de control
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            AdaptiveAIService.resetLearning();
                            _showSnackBar('Datos de IA reiniciados');
                          },
                          child: Text('Reiniciar IA'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            _showSnackBar('Pantalla actualizada');
                          },
                          child: Text('Actualizar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: value == true || value == 'large' ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
