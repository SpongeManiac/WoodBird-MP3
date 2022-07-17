import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../shared/baseApp.dart';
import '../globals.dart' as globals;

BaseApp getApp() {
  return DesktopApp(
    navTitle: 'DesktopApp',
  );
}

class DesktopApp extends BaseApp {
  DesktopApp({super.key, super.navTitle}) : super();

  final dbName = 'db';
  final dbType = '.sqlite';

  bool get isMobile {
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<Directory> dbFolder() async {
    return getApplicationDocumentsDirectory();
  }

  Future<String> dbPath() async {
    return p.join((await dbFolder()).path, '$dbName$dbType');
  }

  @override
  Future<void> closeApp(BuildContext context) async {
    if (kIsWeb) return;
    if (isMobile) {
      bool result = false;
      result = await navigation.exitDialog(context);
      if (result) {
        if (Platform.isAndroid) {
          //Android
          SystemNavigator.pop();
        } else {
          // IOS
          exit(0);
        }
      }
    } else {
      //desktop
      FlutterWindowClose.closeWindow();
    }
  }

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> with WidgetsBindingObserver {
  _DesktopAppState();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        {
          print('App is inactive');
        }
        break;
      case AppLifecycleState.paused:
        {
          print('App is paused');
        }
        break;
      case AppLifecycleState.detached:
        {
          print('App is detatched');
        }
        break;
      case AppLifecycleState.resumed:
        {
          print('App is resumed');
          setState(() {});
        }
        break;
    }
  }

  @override
  dispose() {
    super.dispose();
    print('disposing app');
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MaterialColor>(
        //the listener
        valueListenable: globals.app.themeNotifier,
        //underscores are used for unused variables. Give variable name for listener value.
        builder: (context, themeColor, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: widget.appTitle,
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not rest
              //use new themeColor
              primarySwatch: themeColor,
            ),
            home: widget.appScaffold(),
          );
        });
  }
}
