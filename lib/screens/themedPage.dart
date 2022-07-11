import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../widgets/hideableFloatingAction.dart';

abstract class ThemedPage extends StatefulWidget {
  ThemedPage({
    super.key,
    required this.title,
  }) : super();

  final ValueNotifier<MaterialColor> themeNotifier = globals.app.themeNotifier;
  final String title;

  void initFloatingAction([void Function()? action, Icon? icon]) {
    //Run code after page is done building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //update hideableFloatingAction's data
      globals.app.floatingActionNotifier.value = HideableFloatingActionData(
        true,
        action,
        icon,
      );
    });
  }

  void setNavTitle(String title) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globals.app.setNavTitle(title);
    });
  }

  void initState(BuildContext context) {
    setNavTitle(title);
  }
}
