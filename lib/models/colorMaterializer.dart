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
}
