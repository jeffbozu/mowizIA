import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../widgets/top_bar.dart';
import '../widgets/progress_bar.dart';
import '../services/websocket_service.dart';
import '../services/dynamic_translations_service.dart';

class PlateScreen extends StatefulWidget {
  const PlateScreen({super.key});

  @override
  State<PlateScreen> createState() => _PlateScreenState();
}

class _PlateScreenState extends State<PlateScreen> {
  final TextEditingController _plateController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _plateController.addListener(_validatePlate);
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _validatePlate() {
    final plate = _plateController.text.toUpperCase();
    setState(() {
      _isValid = MockData.validatePlate(plate);
    });
  }

  void _clearPlate() {
    _plateController.clear();
  }

  void _next() {
    if (_isValid) {
      // Guardar la matrícula en el estado global
      AppState.setCurrentPlate(_plateController.text.toUpperCase());
      print('📝 Matrícula guardada en estado: ${AppState.currentPlate}');
      context.push('/tiempo');
    }
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
            title: DynamicTranslationsService.instance.t('plate.title', defaultValue: 'Matrícula'),
            showBackButton: true,
            onBack: () => context.go('/home'), // Navegar específicamente a home
          ),
          // Barra de progreso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ProgressBar(currentStep: 1),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Icono de matrícula
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Título
                  Text(
                    DynamicTranslationsService.instance.t('plate.title', defaultValue: 'Matrícula'),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo
                  Text(
                    DynamicTranslationsService.instance.t('plate.hint', defaultValue: 'Introduce la matrícula de tu vehículo'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Campo de entrada
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isValid
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _plateController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: '1234ABC',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          fontSize: 32,
                          letterSpacing: 2,
                        ),
                        border: InputBorder.none,
                        suffixIcon: _plateController.text.isNotEmpty
                            ? IconButton(
                                onPressed: _clearPlate,
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        // Convertir a mayúsculas automáticamente
                        if (value != value.toUpperCase()) {
                          _plateController.value = TextEditingValue(
                            text: value.toUpperCase(),
                            selection: TextSelection.collapsed(offset: value.length),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Mensaje de validación
                  if (_plateController.text.isNotEmpty)
                    Text(
                      _isValid
                          ? DynamicTranslationsService.instance.t('plate.valid', defaultValue: 'Matrícula válida')
                          : DynamicTranslationsService.instance.t('plate.invalid_format', defaultValue: 'Formato de matrícula inválido'),
                      style: TextStyle(
                        color: _isValid
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Spacer(),
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: Text(DynamicTranslationsService.instance.t('plate.back', defaultValue: 'Atrás')),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isValid ? _next : null,
                          child: Text(DynamicTranslationsService.instance.t('plate.next', defaultValue: 'Continuar')),
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
}