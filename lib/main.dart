import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'globals.dart' as globals;

import 'package:provider/provider.dart';
import 'package:test_project/database/connection/shared.dart';
import 'package:test_project/database/database.dart';

import 'models/tables/homePageData.dart';

void main() {
  //load page states
  () async {
    // if (!kIsWeb) {
    //   String path = await globals.dbPath();
    //   final file = File(path);
    //   file.delete();
    // }
    //get homepagestate db object
    var homeStateDB = await globals.db.getHomeState();
    homeStateDB ??= HomePageStateDB(id: 1, theme: 0, count: 0);
    if (homeStateDB.theme < 0 || homeStateDB.theme >= globals.themes.length) {
      homeStateDB = HomePageStateDB(id: 1, theme: 0, count: homeStateDB.count);
    }
    //convert homepagestate db object to homepagedata
    HomePageData homeState = HomePageData(homeStateDB.theme, homeStateDB.count);
    //set global values
    globals.homePageStateNotifier.value = homeState;
    MaterialColor theme = globals.themes.values.elementAt(homeStateDB.theme);
    globals.themeNotifier.value = theme;
    print(homeState.theme);
    print(globals.homePageStateNotifier.value.theme);
    print(homeState.count);
    print(globals.homePageStateNotifier.value.count);
  }();

  runApp(
    Provider<SharedDatabase>(
      create: (context) => constructDb(),
      child: const MyApp(),
      dispose: (_, db) => db.close(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //creates a new material app when _themeNotifier changes
    return ValueListenableBuilder<MaterialColor>(
        //the listener
        valueListenable: globals.themeNotifier,
        //underscores are used for unused variables. Give variable name for listener value.
        builder: (context, themeColor, __) {
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
            home: globals.appScaffold,
          );
        });
  }
}
