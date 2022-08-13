import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:test_project/screens/themedPage.dart';
import 'package:test_project/widgets/playerMenu.dart';

import '../globals.dart' show app;
import '../widgets/hideableFloatingAction.dart';

class PageNav extends StatefulWidget {
  PageNav({
    super.key,
  }) : super();

  bool _alertShowing = false;

  Future<bool> Function() androidOnBack = () async {
    print('default back');
    return true;
  };

  Future<bool> exitDialog(BuildContext context) async {
    print('running alert');
    if (_alertShowing) {
      print('alert is showing: $_alertShowing');
      return false;
    }
    _alertShowing = true;
    //print('awaiting show dialog');
    bool? result = await showDialog(
        context: context,
        builder: (context) {
          print('building dialog');
          return AlertDialog(
              title: const Text('Do you really want to quit?'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      _alertShowing = false;
                    },
                    child: Text(
                      'Yes',
                      style: TextStyle(
                          color:
                              Theme.of(context).primaryTextTheme.button!.color),
                    )),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 202, 202, 202)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      _alertShowing = false;
                    },
                    child: const Text('No'))
              ]);
        });
    //print('Alert is gone');
    _alertShowing = false;
    result ??= false;
    if (result) {
      app.appCleanup();
    }
    return result;
  }

  void setWebExitAlert(String alert) {
    FlutterWindowClose.setWebReturnValue(alert);
  }

  void setAppExitAlert(
    Future<bool> Function(BuildContext context) asyncResult,
    BuildContext context,
  ) {
    print('setting app exit alert');
    Future<bool> result() async {
      return await asyncResult(context);
    }

    FlutterWindowClose.setWindowShouldCloseHandler(result);
  }

  void goto(BuildContext context, String route, [bool popNav = false]) {
    if (app.routes.containsKey(route)) {
      if (route != app.currentRoute) {
        print('resetting back button');
        androidOnBack = () async {
          goto(context, '/');
          return false;
        };
        app.currentRoute = route;
        app.floatingActionNotifier.value = HideableFloatingActionData(false);
        app.routeNotifier.value = route;
      } else {
        //when same route
      }
    } else {
      //when route doesn't exist
    }
    if (popNav) {
      Navigator.pop(context);
    }
  }

  @override
  State<PageNav> createState() => _PageNavState();

  void initState(context) {
    //set exit alert
    if (kIsWeb) {
      setWebExitAlert('Leaving page could cause data loss.');
    } else {
      setAppExitAlert(exitDialog, context);
    }
  }
}

class _PageNavState extends State<PageNav> {
  _PageNavState() : super();

  double seeker = 0;

  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: app.routeNotifier,
      builder: (_, newRoute, __) {
        ThemedPage Function(BuildContext)? builder = app.routes[newRoute];
        if (builder == null) {
          builder = app.routes['/'];
          app.currentRoute = '/';
        } else {
          //reset back button function
          app.currentRoute = newRoute;
        }
        var size = MediaQuery.of(context).size;
        //print('size: $size');
        int maxHeight = MediaQuery.of(context).size.shortestSide.ceil();
        //print('Max height: $maxHeight');
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: WillPopScope(
                onWillPop: () => widget.androidOnBack(),
                child: builder!(context),
              ),
            ),
            SlidingUpPanel(
              //margin: EdgeInsets.only(top: 60),
              //color: Theme.of(context),
              minHeight: 100,
              maxHeight: maxHeight.toDouble(),
              panel: PlayerMenu(),
            ),
          ],
        );
      },
    );
  }
}
