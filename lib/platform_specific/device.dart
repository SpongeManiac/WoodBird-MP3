import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/models/colorMaterializer.dart';

import '../models/states/pages/homePageData.dart';
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
    var path = p.join((await dbFolder()).path, '$dbName$dbType');
    print('db path: $path');
    return path;
  }

  Future<bool> closeDialog(BuildContext context) async {
    bool result = await navigation.exitDialog(context);
    print('closeDialog result: $result');
    return result;
  }

  @override
  Future<void> closeApp(BuildContext context) async {
    if (kIsWeb) return;
    if (isMobile) {
      bool result = await closeDialog(context);
      print('got dialog result');
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
          //setState(() {});
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
    return ValueListenableBuilder<HomePageData>(
      valueListenable: widget.homePageStateNotifier,
      builder: ((context, settings, _) {
        //print(globals.themes);
        //print(settings.theme);
        MaterialColor? color = globals.app.theme;
        print(color);
        //print(globals.app.theme);
        //var bColor = settings.darkMode ? color.shade900 : null;
        final ColorScheme schemeLight = ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: color.shade500,
          primary: color.shade500,
          secondary: color.shade500,
        );

        final ColorScheme schemeDark = ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: color.shade500,
          primary: color.shade500,
          secondary: color.shade500,
        );

        var themeLight = ThemeData(
          //brightness: Brightness.light,
          colorScheme: schemeLight,
          primaryColor: schemeLight.primary,
          primaryColorLight: Color.alphaBlend(
              Colors.white.withOpacity(0.1), schemeLight.primary),
          primaryColorDark: Color.alphaBlend(
              Colors.black.withOpacity(0.2), schemeLight.primary),
          secondaryHeaderColor: Color.alphaBlend(
              Colors.white.withOpacity(0.1), schemeLight.primary),
          appBarTheme: AppBarTheme(color: schemeLight.primary),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
              return schemeLight.primary;
            }),
          ),
          toggleableActiveColor: schemeLight.secondary,
          scaffoldBackgroundColor: schemeLight.background,
          canvasColor: schemeLight.background,
          backgroundColor: schemeLight.background,
          cardColor: schemeLight.surface,
          bottomAppBarColor: schemeLight.surface,
          dialogBackgroundColor: schemeLight.surface,
          indicatorColor: schemeLight.onPrimary,
          dividerColor: schemeLight.onSurface.withOpacity(0.12),
          errorColor: schemeLight.error,
          applyElevationOverlayColor: false,
        );

        var themeDark = ThemeData(
          //brightness: Brightness.dark,
          colorScheme: schemeDark,
          primaryColor: schemeDark.primary,
          primaryColorLight: Color.alphaBlend(
              Colors.white.withOpacity(0.1), schemeDark.primary),
          primaryColorDark: Color.alphaBlend(
              Colors.black.withOpacity(0.2), schemeDark.primary),
          secondaryHeaderColor: Color.alphaBlend(
              Colors.black.withOpacity(0.1), schemeDark.primary),
          appBarTheme: AppBarTheme(color: schemeDark.primary),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
              return schemeLight.primary;
            }),
          ),
          toggleableActiveColor: schemeDark.secondary,
          scaffoldBackgroundColor: schemeDark.background,
          canvasColor: schemeDark.background,
          backgroundColor: schemeDark.background,
          cardColor: schemeDark.surface,
          bottomAppBarColor: schemeDark.surface,
          dialogBackgroundColor: schemeDark.surface,
          indicatorColor: schemeDark.primary,
          dividerColor: schemeDark.onSurface.withOpacity(0.12),
          errorColor: schemeDark.error,
          applyElevationOverlayColor: true,
          // buttonTheme: ButtonThemeData(

          // ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: widget.appTitle,
          theme: settings.darkMode ? themeDark : themeLight,
          //darkTheme: themeDark,
          home: widget.appScaffold(),
          //navigatorKey: widget.navKey,
        );
      }),
    );
  }
}
