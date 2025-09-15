import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class ExtendScreen extends StatelessWidget {
  const ExtendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Text('Pantalla de Extender - En desarrollo'),
      ),
    );
  }
}
