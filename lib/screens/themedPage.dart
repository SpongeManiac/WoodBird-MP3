import 'package:flutter/material.dart';
import 'package:test_project/database/database.dart';
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
  SharedDatabase get db => globals.db;

  MaterialColor get theme => globals.app.theme;

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

  void setAndroidBack(BuildContext context, Future<bool> Function() callback,
      [IconData? appBarIcon]) {
    app.navigation.setAndroidOnBack(context, callback, appBarIcon);
  }

  void initState(BuildContext context) {
    app.navigation.setAppBarTitle(title);
  }

  Future<void> saveState() async {}
}
