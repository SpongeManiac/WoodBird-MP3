import 'dart:ui';

import 'package:flutter/material.dart';

class ColorMaterializer {
  static Map<int, Color> getMap(Color color) {
    return {
      50: lighten(color, 80),
      100: lighten(color, 70),
      200: lighten(color, 60),
      300: lighten(color, 50),
      400: lighten(color, 40),
      500: color,
      600: darken(color, 20),
      700: darken(color, 40),
      800: darken(color, 60),
      900: darken(color, 80),
    };
  }

  static MaterialColor getMaterial(Color color) {
    return MaterialColor(color.value, getMap(color));
  }

  /// Darken a color by [percent] amount (100 = black)
// ........................................................
  static Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
        (c.blue * f).round());
  }

  /// Lighten a color by [percent] amount (100 = white)
// ........................................................
  static Color lighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha,
        c.red + ((255 - c.red) * p).round(),
        c.green + ((255 - c.green) * p).round(),
        c.blue + ((255 - c.blue) * p).round());
  }

  static ThemeBundle getTheme(Color color, [bool darkMode = false]) {
    MaterialColor colorMat = getMaterial(color);
    ColorScheme scheme;
    ThemeData data;
    if (darkMode) {
      scheme = ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: colorMat.shade500,
        primary: colorMat.shade500,
        secondary: colorMat.shade500,
      );

      data = ThemeData(
        //brightness: Brightness.dark,
        colorScheme: scheme,
        primaryColor: scheme.primary,
        primaryColorLight:
            Color.alphaBlend(Colors.white.withOpacity(0.1), scheme.primary),
        primaryColorDark:
            Color.alphaBlend(Colors.black.withOpacity(0.2), scheme.primary),
        secondaryHeaderColor:
            Color.alphaBlend(Colors.black.withOpacity(0.1), scheme.primary),
        appBarTheme: AppBarTheme(color: scheme.primary),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            return scheme.primary;
          }),
        ),
        toggleableActiveColor: scheme.secondary,
        scaffoldBackgroundColor: scheme.background,
        canvasColor: scheme.background,
        backgroundColor: scheme.background,
        cardColor: scheme.surface,
        bottomAppBarColor: scheme.surface,
        dialogBackgroundColor: scheme.surface,
        indicatorColor: scheme.primary,
        dividerColor: scheme.onSurface.withOpacity(0.12),
        errorColor: scheme.error,
        applyElevationOverlayColor: true,
        // buttonTheme: ButtonThemeData(

        // ),
      );
    } else {
      scheme = ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: colorMat.shade500,
        primary: colorMat.shade500,
        secondary: colorMat.shade500,
      );

      data = ThemeData(
        //brightness: Brightness.light,
        colorScheme: scheme,
        primaryColor: scheme.primary,
        primaryColorLight:
            Color.alphaBlend(Colors.white.withOpacity(0.1), scheme.primary),
        primaryColorDark:
            Color.alphaBlend(Colors.black.withOpacity(0.2), scheme.primary),
        secondaryHeaderColor:
            Color.alphaBlend(Colors.white.withOpacity(0.1), scheme.primary),
        appBarTheme: AppBarTheme(color: scheme.primary),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            return scheme.primary;
          }),
        ),
        toggleableActiveColor: scheme.secondary,
        scaffoldBackgroundColor: scheme.background,
        canvasColor: scheme.background,
        backgroundColor: scheme.background,
        cardColor: scheme.surface,
        bottomAppBarColor: scheme.surface,
        dialogBackgroundColor: scheme.surface,
        indicatorColor: scheme.onPrimary,
        dividerColor: scheme.onSurface.withOpacity(0.12),
        errorColor: scheme.error,
        applyElevationOverlayColor: false,
      );
    }
    return ThemeBundle(scheme, data);
  }
}

class ThemeBundle {
  ThemeBundle(this.scheme, this.data);
  ColorScheme scheme;
  ThemeData data;
}
