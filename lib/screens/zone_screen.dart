import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class ZoneScreen extends StatelessWidget {
  const ZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Text('Pantalla de Zona - En desarrollo'),
      ),
    );
  }
}
