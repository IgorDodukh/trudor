import 'package:trudor/core/constant/colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: kLightPrimaryColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: kBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: kLightSecondaryColor,
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: kLightSecondaryColor)),
    colorScheme: ColorScheme.light(secondary: kLightSecondaryColor)
        .copyWith(background: kLightBackgroundColor),
  );

  static final darkTheme = ThemeData(
      // brightness: Brightness.dark,
      primaryColor: kDarkPrimaryColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kDarkTextColor)),
      colorScheme: ColorScheme.dark(background: kDarkBackgroundColor)
          .copyWith(secondary: kDarkBackgroundColor, brightness: Brightness.dark));
}
