import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../widgets/top_bar.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  @override
  void initState() {
    super.initState();
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
            title: AppStrings.t('access.title'),
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Icono de accesibilidad
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.accessibility_new,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Título
                  Text(
                    AppStrings.t('access.title'),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Opciones de accesibilidad
                  Card(
                    child: Column(
                      children: [
                        // Modo oscuro
                        SwitchListTile(
                          title: Text(
                            AppStrings.t('access.dark_mode'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(
                            AppStrings.t('access.dark_mode.desc'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          value: AppState.darkMode,
                          onChanged: _toggleDarkMode,
                          secondary: Icon(
                            AppState.darkMode ? Icons.dark_mode : Icons.light_mode,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Divider(),
                        // Alto contraste
                        SwitchListTile(
                          title: Text(
                            AppStrings.t('access.high_contrast'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(
                            AppStrings.t('access.high_contrast.desc'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          value: AppState.highContrast,
                          onChanged: _toggleHighContrast,
                          secondary: Icon(
                            Icons.contrast,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Divider(),
                        // Tamaño de fuente
                        ListTile(
                          title: Text(
                            AppStrings.t('access.font_size'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(
                            AppStrings.t('access.font_size.desc'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          leading: Icon(
                            Icons.text_fields,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          trailing: DropdownButton<String>(
                            value: AppState.fontSize,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _setFontSize(newValue);
                              }
                            },
                            items: <String>['small', 'normal', 'large']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(_getFontSizeLabel(value)),
                              );
                            }).toList(),
                          ),
                        ),
                        const Divider(),
                        // Reducir animaciones
                        SwitchListTile(
                          title: Text(
                            AppStrings.t('access.reduce_animations'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(
                            AppStrings.t('access.reduce_animations.desc'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          value: AppState.reduceAnimations,
                          onChanged: _toggleReduceAnimations,
                          secondary: Icon(
                            Icons.speed,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: Text(AppStrings.t('access.back')),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _apply,
                          child: Text(AppStrings.t('access.apply')),
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

  void _toggleDarkMode(bool value) {
    setState(() {
      AppState.darkMode = value;
    });
    AppState.notifyAccessibilityChange();
  }

  void _toggleHighContrast(bool value) {
    setState(() {
      AppState.highContrast = value;
    });
    AppState.notifyAccessibilityChange();
  }

  void _setFontSize(String size) {
    setState(() {
      AppState.fontSize = size;
    });
    AppState.notifyAccessibilityChange();
  }

  void _toggleReduceAnimations(bool value) {
    setState(() {
      AppState.reduceAnimations = value;
    });
    AppState.notifyAccessibilityChange();
  }

  void _apply() {
    // Los cambios ya se aplican automáticamente al cambiar el estado
    context.pop();
  }

  String _getFontSizeLabel(String size) {
    switch (size) {
      case 'small':
        return AppStrings.t('access.font_size.small');
      case 'large':
        return AppStrings.t('access.font_size.large');
      default:
        return AppStrings.t('access.font_size.normal');
    }
  }
}