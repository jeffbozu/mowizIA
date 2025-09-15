import 'package:flutter/material.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MEYPARKApp());
}

class MEYPARKApp extends StatelessWidget {
  const MEYPARKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MEYPARK',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppTheme.darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}