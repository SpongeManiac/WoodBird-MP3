import 'package:flutter/material.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/shared/baseApp.dart';
import 'package:test_project/widgets/appBar.dart';
import '../globals.dart' as globals;
import '../models/contextItemTuple.dart';
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
    app.navigation.setAndroidBackAction(context, callback, appBarIcon);
  }

  void initState(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      app.navigation.setAppBarTitle(title);
    });
  }

  List<PopupMenuItem<String>> buildPopupItems(
      BuildContext context, Map<String, ContextItemTuple> items) {
    List<PopupMenuItem<String>> contextButtonItems = [];
    for (String val in items.keys) {
      var choice = items[val];
      contextButtonItems.add(
        PopupMenuItem(
          onTap: choice!.onPress,
          child: Row(
            children: [
              Icon(
                choice.icon,
                color: Theme.of(context).primaryColor,
              ),
              Expanded(
                child: Text(
                  val,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return contextButtonItems;
  }

  Future<void> saveState() async {}
}
