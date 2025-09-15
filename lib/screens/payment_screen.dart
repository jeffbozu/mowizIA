import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Text('Pantalla de Pago - En desarrollo'),
      ),
    );
  }
}
