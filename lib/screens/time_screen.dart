import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class TimeScreen extends StatelessWidget {
  const TimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Text('Pantalla de Tiempo - En desarrollo'),
      ),
    );
  }
}
