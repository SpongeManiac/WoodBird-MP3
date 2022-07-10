import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../widgets/hideableFloatingAction.dart';

abstract class ThemedPage extends StatefulWidget {
  ThemedPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final ValueNotifier<MaterialColor> themeNotifier = globals.themeNotifier;
  final String title;

  void initFloatingAction([void Function()? action, Icon? icon]) {
    //Run code after page is done building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //update hideableFloatingAction's data
      globals.floatingActionNotifier.value = HideableFloatingActionData(
        true,
        action,
        icon,
      );
    });
  }
}
