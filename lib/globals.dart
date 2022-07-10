library test_project;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:test_project/database/connection/native.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/widgets/hideableFloatingAction.dart';
import 'models/tables/homePageData.dart';
import 'screens/homePage.dart';
import 'screens/songPage.dart';
import 'screens/themedPage.dart';
import 'widgets/flyout/flyout.dart';
import 'screens/pageNav.dart';

Future<Directory> get dbFolder async {
  return getApplicationDocumentsDirectory();
}

final dbName = 'db';
final dbType = '.sqlite';

Future<String> dbPath() async {
  if (!kIsWeb) {
    return p.join((await dbFolder).path, '$dbName$dbType');
  } else {
    return '';
  }
}

SharedDatabase? _db;
//reference to db
SharedDatabase get db => _db ??= constructDb();

//themes
const Map<String, MaterialColor> themes = {
  'Blue': Colors.blue,
  'Red': Colors.red,
  'Purple': Colors.purple,
  'Teal': Colors.teal,
  'Orange': Colors.orange,
};

//global notifiers
final ValueNotifier<MaterialColor> themeNotifier = ValueNotifier(Colors.blue);
final ValueNotifier<String> routeNotifier = ValueNotifier('/');
final ValueNotifier<HideableFloatingActionData> floatingActionNotifier =
    ValueNotifier(HideableFloatingActionData(false));

//homepage
final ValueNotifier<HomePageData> homePageStateNotifier =
    ValueNotifier(HomePageData(0, 0));

final Map<String, ThemedPage Function(BuildContext)> routes = {
  '/': (context) => HomePage(title: 'Home'),
  '/files': (context) => SongsPage(title: 'Songs'),
};

String currentRoute = '/';

const Flyout flyout = Flyout();
const PageNav navigation = PageNav();
HideableFloatingAction floatingActionButton = const HideableFloatingAction();

final Scaffold appScaffold = Scaffold(
  appBar: AppBar(
    // Here we take the value from the MyHomePage object that was created by
    // the App.build method, and use it to set our appbar title.
    title: const Text('Title'),
  ),
  drawer: flyout,
  body: navigation,
  floatingActionButton: floatingActionButton,
);
