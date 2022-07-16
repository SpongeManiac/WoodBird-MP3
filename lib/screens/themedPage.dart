import 'package:flutter/material.dart';
import 'package:test_project/models/states/baseState.dart';
import 'package:test_project/widgets/appBar.dart';
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

  AppBarData getDefaultAppBar() {
    return AppBarData(title, null);
  }

  void setAppBarData(AppBarData data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globals.app.appBarNotifier.value = data;
    });
  }

  void setAppBarTitle(String title) {
    AppBarData tmp = globals.app.appBarNotifier.value.copy();
    tmp.title = title;
    setAppBarData(tmp);
  }

  void setAppBarActions(List<Widget> actions) {
    AppBarData tmp = globals.app.appBarNotifier.value.copy();
    tmp.actions = actions;
    setAppBarData(tmp);
  }

  void initState(BuildContext context) {
    setAppBarData(getDefaultAppBar());
  }

  Future<void> saveState();
}
