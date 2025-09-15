import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MEYPARK',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE62144),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Kiosco de Parquímetro',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF7F7F7F),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Hello MEYPARK - Etapa 1',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
