import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_project/database/connection/shared.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/screens/homePage.dart';
import 'package:test_project/screens/songPage.dart';

void main() {
  runApp(
    Provider<SharedDatabase>(
      create: (context) => constructDb(),
      child: MyApp(),
      dispose: (context, db) => db.close(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ValueNotifier<MaterialColor> _themeNotifier =
      ValueNotifier(Colors.blue);

  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //creates a new material app when _themeNotifier changes
    return ValueListenableBuilder<MaterialColor>(
        //the listener
        valueListenable: _themeNotifier,
        //underscores are used for unused variables. Give variable name for listener value.
        builder: (_, themeColor, __) {
          return MaterialApp(
            title: 'WoodBird MP3',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.

              //use new themeColor
              primarySwatch: themeColor,
            ),
            home: HomePage(
              title: 'Home',
              themeNotifier: _themeNotifier,
            ),
            routes: <String, WidgetBuilder>{
              '/songs': (context) =>
                  SongsPage(title: 'Songs', themeNotifier: _themeNotifier),
            },
          );
        });
  }
}
