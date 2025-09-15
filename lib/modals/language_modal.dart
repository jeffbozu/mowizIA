import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';

class LanguageModal extends StatefulWidget {
  const LanguageModal({super.key});

  @override
  State<LanguageModal> createState() => _LanguageModalState();
}

class _LanguageModalState extends State<LanguageModal> {
  String _selectedLocale = AppStrings.currentLocale;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.t('lang.title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: Text(AppStrings.t('lang.es')),
            value: 'es-ES',
            groupValue: _selectedLocale,
            onChanged: (value) {
              setState(() {
                _selectedLocale = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text(AppStrings.t('lang.en')),
            value: 'en',
            groupValue: _selectedLocale,
            onChanged: (value) {
              setState(() {
                _selectedLocale = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(AppStrings.t('lang.cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            AppStrings.setLocale(_selectedLocale);
            context.pop();
            // Forzar rebuild de la app para aplicar el nuevo idioma
            // En una implementación real, esto se haría con un StateManager
          },
          child: Text(AppStrings.t('lang.save')),
        ),
      ],
    );
  }
}
