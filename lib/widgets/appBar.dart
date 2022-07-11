import 'package:flutter/material.dart';
import '../globals.dart' as globals;

class AppBarTitleListener extends AppBar {
  AppBarTitleListener({Key? key}) : super(key: key);

  @override
  State<AppBarTitleListener> createState() => _AppBarTitleListenerState();
}

class _AppBarTitleListenerState extends State<AppBarTitleListener> {
  _AppBarTitleListenerState();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        //the listener
        valueListenable: globals.app.pageTitleNotifier,
        //underscores are used for unused variables. Give variable name for listener value.
        builder: (context, newTitle, __) {
          return AppBar(
            title: Text(newTitle),
          );
        });
  }
}
