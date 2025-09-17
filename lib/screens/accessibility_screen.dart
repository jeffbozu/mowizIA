import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../widgets/top_bar.dart';
import '../services/voice_guide_service.dart';
import '../services/adaptive_ai_service.dart';
import '../services/simplified_mode_service.dart';

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
                        Row(
                          children: [
                            Expanded(
              child: SwitchListTile(
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
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () => _showInfoDialog('dark_mode'),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Alto contraste
                        Row(
                          children: [
                            Expanded(
              child: SwitchListTile(
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
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () => _showInfoDialog('high_contrast'),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Tamaño de fuente
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
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
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () => _showInfoDialog('font_size'),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Guía por voz
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: Text(
                                  AppStrings.t('access.voice_guide'),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                subtitle: Text(
                                  AppStrings.t('access.voice_guide.desc'),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                value: AppState.voiceGuideEnabled,
                                onChanged: _toggleVoiceGuide,
                                secondary: Icon(
                                  AppState.voiceGuideEnabled ? Icons.record_voice_over : Icons.voice_over_off,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () => _showInfoDialog('voice_guide'),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Controles de voz (solo si guía por voz está habilitada)
                        if (AppState.voiceGuideEnabled) ...[
                          // Velocidad de voz
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    AppStrings.t('access.voice_speed'),
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  subtitle: Text(
                                    AppStrings.t('access.voice_speed.desc'),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.speed,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  trailing: SizedBox(
                                    width: 200,
                                    child: Slider(
                                      value: AppState.voiceSpeed,
                                      min: 0.1,
                                      max: 1.0,
                                      divisions: 9,
                                      label: '${(AppState.voiceSpeed * 100).round()}%',
                                      onChanged: _setVoiceSpeed,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () => _showInfoDialog('voice_speed'),
                              ),
                            ],
                          ),
                          const Divider(),
                          // Tono de voz
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    AppStrings.t('access.voice_pitch'),
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  subtitle: Text(
                                    AppStrings.t('access.voice_pitch.desc'),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.tune,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  trailing: SizedBox(
                                    width: 200,
                                    child: Slider(
                                      value: AppState.voicePitch,
                                      min: 0.5,
                                      max: 2.0,
                                      divisions: 15,
                                      label: '${AppState.voicePitch.toStringAsFixed(1)}x',
                                      onChanged: _setVoicePitch,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () => _showInfoDialog('voice_pitch'),
                              ),
                            ],
                          ),
                          const Divider(),
                          // Volumen de voz
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    AppStrings.t('access.voice_volume'),
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  subtitle: Text(
                                    AppStrings.t('access.voice_volume.desc'),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.volume_up,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  trailing: SizedBox(
                                    width: 200,
                                    child: Slider(
                                      value: AppState.voiceVolume,
                                      min: 0.0,
                                      max: 1.0,
                                      divisions: 10,
                                      label: '${(AppState.voiceVolume * 100).round()}%',
                                      onChanged: _setVoiceVolume,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () => _showInfoDialog('voice_volume'),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                        // IA Adaptativa
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: Text(
                                  AppStrings.t('access.adaptive_ai'),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                subtitle: Text(
                                  AppStrings.t('access.adaptive_ai.desc'),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                value: AppState.adaptiveAI,
                                onChanged: _toggleAdaptiveAI,
                                secondary: Icon(
                                  Icons.psychology,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () => _showInfoDialog('adaptive_ai'),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Modo Simplificado
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: Text(
                                  AppStrings.t('access.simplified_mode'),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                subtitle: Text(
                                  AppStrings.t('access.simplified_mode.desc'),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                value: AppState.simplifiedMode,
                                onChanged: _toggleSimplifiedMode,
                                secondary: Icon(
                                  Icons.format_align_left,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () => _showInfoDialog('simplified_mode'),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Reducir animaciones
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
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
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () => _showInfoDialog('reduce_animations'),
                            ),
                          ],
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

  void _toggleVoiceGuide(bool value) {
    setState(() {
      AppState.voiceGuideEnabled = value;
    });
    AppState.notifyAccessibilityChange();
  }

  void _setVoiceSpeed(double value) {
    setState(() {
      AppState.voiceSpeed = value;
    });
    // Actualizar configuración de voz inmediatamente
    VoiceGuideService.updateVoiceSettings();
  }

  void _setVoicePitch(double value) {
    setState(() {
      AppState.voicePitch = value;
    });
    // Actualizar configuración de voz inmediatamente
    VoiceGuideService.updateVoiceSettings();
  }

  void _setVoiceVolume(double value) {
    setState(() {
      AppState.voiceVolume = value;
    });
    // Actualizar configuración de voz inmediatamente
    VoiceGuideService.updateVoiceSettings();
  }

  void _toggleAdaptiveAI(bool value) {
    setState(() {
      AppState.adaptiveAI = value;
    });
    AdaptiveAIService.setEnabled(value);
    AppState.notifyAccessibilityChange();
  }

  void _toggleSimplifiedMode(bool value) {
    setState(() {
      AppState.simplifiedMode = value;
    });
    SimplifiedModeService.setEnabled(value);
    AppState.notifyAccessibilityChange();
  }

  void _showInfoDialog(String type) {
    String title;
    String content;
    
    switch (type) {
      case 'dark_mode':
        title = AppStrings.t('access.dark_mode');
        content = AppStrings.t('access.dark_mode.info');
        break;
      case 'high_contrast':
        title = AppStrings.t('access.high_contrast');
        content = AppStrings.t('access.high_contrast.info');
        break;
      case 'font_size':
        title = AppStrings.t('access.font_size');
        content = AppStrings.t('access.font_size.info');
        break;
      case 'voice_guide':
        title = AppStrings.t('access.voice_guide');
        content = AppStrings.t('access.voice_guide.info');
        break;
      case 'voice_speed':
        title = AppStrings.t('access.voice_speed');
        content = AppStrings.t('access.voice_speed.info');
        break;
      case 'voice_pitch':
        title = AppStrings.t('access.voice_pitch');
        content = AppStrings.t('access.voice_pitch.info');
        break;
      case 'voice_volume':
        title = AppStrings.t('access.voice_volume');
        content = AppStrings.t('access.voice_volume.info');
        break;
      case 'reduce_animations':
        title = AppStrings.t('access.reduce_animations');
        content = AppStrings.t('access.reduce_animations.info');
        break;
      case 'adaptive_ai':
        title = AppStrings.t('access.adaptive_ai');
        content = AdaptiveAIService.getAIInfo();
        break;
      case 'simplified_mode':
        title = AppStrings.t('access.simplified_mode');
        content = SimplifiedModeService.getInfo();
        break;
      default:
        return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.t('common.ok')),
          ),
        ],
      ),
    );
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