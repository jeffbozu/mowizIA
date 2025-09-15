import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Text('Pantalla de Ticket - En desarrollo'),
      ),
    );
  }
}
