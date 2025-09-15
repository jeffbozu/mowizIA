import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../modals/language_modal.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'MEYPARK',
        style: TextStyle(
          color: Color(0xFFE62144),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const LanguageModal(),
            );
          },
          icon: const Icon(Icons.language, color: Color(0xFF7F7F7F)),
          tooltip: AppStrings.t('lang.title'),
        ),
        IconButton(
          onPressed: () {
            context.push('/accesibilidad');
          },
          icon: const Icon(Icons.accessibility, color: Color(0xFF7F7F7F)),
          tooltip: AppStrings.t('access.title'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
