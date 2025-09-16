import 'package:flutter/material.dart';
import 'tokens.dart';
import '../data/models.dart';

// Función para convertir string de color a Color
Color _parseColor(String colorString) {
  try {
    return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
  } catch (e) {
    return AppTokens.brandPrimary; // Color por defecto
  }
}

class AppTheme {
  static bool get darkMode => AppState.darkMode;
  static bool get highContrast => AppState.highContrast;
  static String get fontSize => AppState.fontSize;
  static bool get reduceAnimations => AppState.reduceAnimations;

  static double getSizeMultiplier() {
    switch (fontSize) {
      case 'small': return 0.85;
      case 'large': return 1.25;
      default: return 1.0;
    }
  }

  static ThemeData get lightTheme {
    // Obtener colores de la empresa actual o usar por defecto
    final primaryColor = AppState.currentCompany != null
        ? _parseColor(AppState.currentCompany!.primaryColor)
        : AppTokens.brandPrimary;
    final backgroundColor = AppState.currentCompany != null
        ? _parseColor(AppState.currentCompany!.backgroundColor)
        : AppTokens.lightSurface;

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: AppTokens.lightOnPrimary,
        secondary: AppTokens.lightSecondary,
        onSecondary: AppTokens.lightOnSecondary,
        surface: backgroundColor,
        onSurface: AppTokens.lightOnSurface,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      pageTransitionsTheme: reduceAnimations
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
              },
            )
          : null,
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      filledButtonTheme: _buildFilledButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      cardTheme: _buildCardTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      appBarTheme: _buildAppBarTheme(),
    );

    return highContrast ? _applyHighContrast(baseTheme) : baseTheme;
  }

  static ThemeData get darkTheme {
    // Obtener colores de la empresa actual o usar por defecto
    final primaryColor = AppState.currentCompany != null
        ? _parseColor(AppState.currentCompany!.primaryColor)
        : AppTokens.brandPrimary;

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: AppTokens.darkOnPrimary,
        secondary: AppTokens.darkSecondary,
        onSecondary: AppTokens.darkOnSecondary,
        surface: AppTokens.darkSurface,
        onSurface: AppTokens.darkOnSurface,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      pageTransitionsTheme: reduceAnimations
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
              },
            )
          : null,
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      filledButtonTheme: _buildFilledButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      cardTheme: _buildCardTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      appBarTheme: _buildAppBarTheme(),
    );

    return highContrast ? _applyHighContrast(baseTheme) : baseTheme;
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? AppTokens.lightOnBackground
        : AppTokens.darkOnBackground;

    final multiplier = getSizeMultiplier();

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: AppTokens.fontSizeHeadline * multiplier,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: AppTokens.fontSizeTitle * multiplier,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontSize: AppTokens.fontSizeXXLarge * multiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: AppTokens.fontSizeXLarge * multiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: AppTokens.fontSizeLarge * multiplier,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: AppTokens.fontSizeLarge * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: AppTokens.fontSizeMedium * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: AppTokens.fontSizeSmall * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: AppTokens.fontSizeLarge * multiplier,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTokens.fontSizeMedium * multiplier,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontSize: AppTokens.fontSizeSmall * multiplier,
        color: baseColor,
      ),
      labelLarge: TextStyle(
        fontSize: AppTokens.fontSizeMedium * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontSize: AppTokens.fontSizeSmall * multiplier,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontSize: AppTokens.fontSizeSmall * multiplier,
        color: baseColor,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    final multiplier = getSizeMultiplier();
    
    return AppBarTheme(
      centerTitle: true,
      elevation: AppTokens.elevationL,
      titleTextStyle: TextStyle(
        fontSize: 28 * multiplier,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(
        size: 24,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    final multiplier = getSizeMultiplier();
    
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(120 * multiplier, 48 * multiplier),
        textStyle: TextStyle(
          fontSize: AppTokens.fontSizeLarge * multiplier,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.borderRadiusM),
        ),
        elevation: AppTokens.elevationM,
      ),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme() {
    final multiplier = getSizeMultiplier();
    
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: Size(120 * multiplier, 48 * multiplier),
        textStyle: TextStyle(
          fontSize: AppTokens.fontSizeLarge * multiplier,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.borderRadiusM),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    final multiplier = getSizeMultiplier();
    
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(120 * multiplier, 48 * multiplier),
        textStyle: TextStyle(
          fontSize: AppTokens.fontSizeLarge * multiplier,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.borderRadiusM),
        ),
        side: const BorderSide(width: 2.0),
      ),
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      elevation: AppTokens.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.borderRadiusL),
      ),
      margin: const EdgeInsets.all(AppTokens.spacingS),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    final multiplier = getSizeMultiplier();
    
    return InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.borderRadiusM),
        borderSide: const BorderSide(width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.borderRadiusM),
        borderSide: const BorderSide(width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.borderRadiusM),
        borderSide: const BorderSide(width: 2.0),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.spacingM * multiplier,
        vertical: AppTokens.spacingM * multiplier,
      ),
      labelStyle: TextStyle(
        fontSize: AppTokens.fontSizeMedium * multiplier,
      ),
    );
  }

  static ThemeData _applyHighContrast(ThemeData baseTheme) {
    final multiplier = getSizeMultiplier();
    
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppTokens.highContrastText,
        onPrimary: AppTokens.highContrastBackground,
        secondary: AppTokens.highContrastText,
        onSecondary: AppTokens.highContrastBackground,
        surface: AppTokens.highContrastBackground,
        onSurface: AppTokens.highContrastText,
        outline: AppTokens.highContrastBorder,
        error: AppTokens.highContrastText,
        onError: AppTokens.highContrastBackground,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: AppTokens.highContrastText,
        displayColor: AppTokens.highContrastText,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
          color: AppTokens.highContrastText,
        ),
        iconTheme: IconThemeData(
          color: AppTokens.highContrastText,
          size: 24 * multiplier,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppTokens.highContrastBackground,
          backgroundColor: AppTokens.highContrastText,
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeLarge * multiplier,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: AppTokens.highContrastBackground,
          backgroundColor: AppTokens.highContrastText,
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeLarge * multiplier,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.highContrastText,
          side: const BorderSide(color: AppTokens.highContrastText, width: 2),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeLarge * multiplier,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}