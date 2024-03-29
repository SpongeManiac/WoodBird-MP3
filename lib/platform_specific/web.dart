import 'package:flutter/material.dart';
import 'package:woodbirdmp3/models/states/pages/homePageData.dart';

import '../globals.dart' as globals;
import '../shared/baseApp.dart';

BaseApp getApp() {
  return WebApp(navTitle: 'WebApp');
}

class WebApp extends BaseApp {
  WebApp({Key? key, String? navTitle}) : super(key: key, navTitle: navTitle);

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  _WebAppState();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomePageData>(
        //the listener
        valueListenable: globals.app.homePageStateNotifier,
        //underscores are used for unused variables. Give variable name for listener value.
        builder: (context, newState, __) {
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
              primarySwatch: widget.theme,
            ),
            home: widget.appScaffold(),
          );
        });
  }
}
