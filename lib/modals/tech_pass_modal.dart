import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';

class TechPassModal extends StatefulWidget {
  const TechPassModal({super.key});

  @override
  State<TechPassModal> createState() => _TechPassModalState();
}

class _TechPassModalState extends State<TechPassModal> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _enter() async {
    if (_passwordController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simular validación
    await Future.delayed(const Duration(seconds: 1));

    if (_passwordController.text == 'Tech#911') {
      // Contraseña correcta
      if (mounted) {
        Navigator.of(context).pop();
        // Usar GoRouter para navegar
        if (context.mounted) {
          context.push('/tecnico');
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
            content: Text(AppStrings.t('techpass.invalid_password')),
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
      title: Text(AppStrings.t('techpass.title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.build,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppStrings.t('techpass.password'),
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _enter(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _cancel,
          child: Text(AppStrings.t('techpass.cancel')),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _enter,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(AppStrings.t('techpass.enter')),
        ),
      ],
    );
  }
}