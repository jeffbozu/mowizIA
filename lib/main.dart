import 'package:flutter/material.dart';
import 'app_router.dart';

void main() {
  runApp(const MEYPARKApp());
}

class MEYPARKApp extends StatelessWidget {
  const MEYPARKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MEYPARK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE62144)),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}