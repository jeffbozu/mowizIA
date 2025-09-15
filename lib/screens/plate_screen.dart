import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class PlateScreen extends StatelessWidget {
  const PlateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Text('Pantalla de Matrícula - En desarrollo'),
      ),
    );
  }
}
