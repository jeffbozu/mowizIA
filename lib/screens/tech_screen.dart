import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class TechScreen extends StatelessWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Text('Pantalla Técnica - En desarrollo'),
      ),
    );
  }
}
