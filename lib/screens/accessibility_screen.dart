import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Text('Pantalla de Accesibilidad - En desarrollo'),
      ),
    );
  }
}
