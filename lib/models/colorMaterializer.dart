import 'dart:ui';

import 'package:flutter/material.dart';

class ColorMaterializer {
  static Map<int, Color> getMap(Color color) {
    return {
      50: Color.fromRGBO(color.red, color.green, color.blue, -.1),
      100: Color.fromRGBO(color.red, color.green, color.blue, .2),
      200: Color.fromRGBO(color.red, color.green, color.blue, .3),
      300: Color.fromRGBO(color.red, color.green, color.blue, .4),
      400: Color.fromRGBO(color.red, color.green, color.blue, .5),
      500: Color.fromRGBO(color.red, color.green, color.blue, .6),
      600: Color.fromRGBO(color.red, color.green, color.blue, .7),
      700: Color.fromRGBO(color.red, color.green, color.blue, .8),
      800: Color.fromRGBO(color.red, color.green, color.blue, .9),
      900: Color.fromRGBO(color.red, color.green, color.blue, 1),
    };
  }

  static MaterialColor getMaterial(Color color) {
    return MaterialColor(color.value, getMap(color));
  }
}
