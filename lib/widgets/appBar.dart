import 'package:drift/src/runtime/data_class.dart';
import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../models/states/baseState.dart';

class AppBarTitleListener extends AppBar {
  AppBarTitleListener({Key? key}) : super(key: key);

  @override
  State<AppBarTitleListener> createState() => _AppBarTitleListenerState();
}

class _AppBarTitleListenerState extends State<AppBarTitleListener> {
  _AppBarTitleListenerState();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppBarData>(
        //the listener
        valueListenable: globals.app.appBarNotifier,
        //underscores are used for unused variables. Give variable name for listener value.
        builder: (context, data, __) {
          return AppBar(
            title: Text(data.title),
            actions: () {
              var actions = data.actions != null ? data.actions! : <Widget>[];
              if (data.onBack != null) {
                actions.add(data.onBack!);
              }
              return actions;
            }(),
          );
        });
  }
}

class AppBarData extends BaseData {
  AppBarData(this.title, [this.actions, this.onBack]);

  String title;
  Widget? onBack;
  List<Widget>? actions;

  @override
  AppBarData copy() {
    return AppBarData(title, actions, onBack);
  }
}
