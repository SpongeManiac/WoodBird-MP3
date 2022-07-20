import 'package:flutter/material.dart';
import 'package:test_project/models/states/baseState.dart';
import 'package:test_project/shared/baseApp.dart';
import 'package:test_project/widgets/appBar.dart';
import '../globals.dart' as globals;
import '../widgets/hideableFloatingAction.dart';

abstract class ThemedPage extends StatefulWidget {
  ThemedPage({
    super.key,
    required this.title,
    this.floatingActionButton = const HideableFloatingAction(),
  }) : super();

  BaseApp get app => globals.app;

  ValueNotifier<MaterialColor> get themeNotifier => app.themeNotifier;
  final String title;
  ValueNotifier<HideableFloatingActionData> get actionButtonNotifier =>
      app.floatingActionNotifier;
  HideableFloatingAction floatingActionButton;

  void initFloatingAction([void Function()? action, Icon? icon]) {
    //Run code after page is done building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //update hideableFloatingAction's data
      actionButtonNotifier.value = HideableFloatingActionData(
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
      app.appBarNotifier.value = data;
    });
  }

  void setAppBarTitle(String title) {
    AppBarData tmp = app.appBarNotifier.value.copy();
    tmp.title = title;
    setAppBarData(tmp);
  }

  void setAppBarActions(List<Widget> actions) {
    AppBarData tmp = app.appBarNotifier.value.copy();
    tmp.actions = actions;
    setAppBarData(tmp);
  }

  void initState(BuildContext context) {
    setAppBarData(getDefaultAppBar());
  }

  Future<void> saveState();
}
