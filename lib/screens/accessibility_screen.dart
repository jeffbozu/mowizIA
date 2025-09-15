import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/top_bar.dart';
import '../i18n/strings.dart';
import '../theme/app_theme.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  bool _darkMode = AppTheme.darkMode;
  bool _highContrast = AppTheme.highContrast;

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
              AppStrings.t('access.title'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Modo Oscuro
            Card(
              child: SwitchListTile(
                title: Text(
                  AppStrings.t('access.dark_mode'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _darkMode ? 'Activado' : 'Desactivado',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                    AppTheme.setDarkMode(value);
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Alto Contraste
            Card(
              child: SwitchListTile(
                title: Text(
                  AppStrings.t('access.high_contrast'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _highContrast ? 'Activado' : 'Desactivado',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                value: _highContrast,
                onChanged: (value) {
                  setState(() {
                    _highContrast = value;
                    AppTheme.setHighContrast(value);
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const Spacer(),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text(AppStrings.t('access.back')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Aplicar cambios y volver
                      context.pop();
                    },
                    child: Text(AppStrings.t('access.apply')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
