import 'package:flutter/material.dart';
import 'package:el_arbol/constants/app_colors.dart';

final class CustomTheme {
  CustomTheme._();
  static const MaterialColor kToDark = MaterialColor(
    0xFF003469, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFF003469), //10%
      100: Color(0xFF003469), //20%
      200: Color(0xFF003469), //30%
      300: Color(0xFF003469), //40%
      400: Color(0xFF003469), //50%
      500: Color(0xFF003469), //60%
      600: Color(0xFF003469), //70%
      700: Color(0xFF003469), //80%
      800: Color(0xFF003469), //80%
      900: Color(0xFF003469), //80%
    },
  );
  static ThemeData get mainTheme {
    return ThemeData(
      primaryColor: AppColors.allPrimaryColor,
      primarySwatch: CustomTheme.kToDark,
      scaffoldBackgroundColor: AppColors.white,
    );
  }
}
