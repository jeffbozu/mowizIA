import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';

class AdminPassModal extends StatefulWidget {
  const AdminPassModal({super.key});

  @override
  State<AdminPassModal> createState() => _AdminPassModalState();
}

class _AdminPassModalState extends State<AdminPassModal> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _access() async {
    if (_passwordController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simular validación
    await Future.delayed(const Duration(seconds: 1));

    if (_passwordController.text == 'Admin#360') {
      // Contraseña correcta
      if (mounted) {
        Navigator.of(context).pop();
        // Usar GoRouter para navegar
        if (context.mounted) {
          context.go('/login');
        }
      }
    } else {
      // Contraseña incorrecta
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('admin.invalid_password')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.t('admin.title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppStrings.t('admin.password'),
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _access(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _cancel,
          child: Text(AppStrings.t('admin.cancel')),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _access,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(AppStrings.t('admin.access')),
        ),
      ],
    );
  }
}