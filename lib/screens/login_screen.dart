import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../i18n/strings.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MEYPARK',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE62144),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kiosco de Parquímetro',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF7F7F7F),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              AppStrings.t('login.title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Hello MEYPARK - Etapa 2',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
