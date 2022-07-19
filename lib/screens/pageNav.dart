import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:test_project/screens/themedPage.dart';
import 'package:test_project/widgets/playerMenu.dart';

import '../database/database.dart';
import '../globals.dart' as globals;
import '../models/states/home/homePageData.dart';
import '../widgets/hideableFloatingAction.dart';

class PageNav extends StatefulWidget {
  PageNav({
    super.key,
  }) : super();

  bool _alertShowing = false;

  Future<bool> exitDialog(BuildContext context) async {
    //print('running alert');
    if (_alertShowing) return false;
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
                    // style: ButtonStyle(
                    //   backgroundColor:
                    //       MaterialStateProperty.all<Color>(Colors.red),
                    // ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      _alertShowing = false;
                    },
                    child: const Text('Yes')),
                ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
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
      globals.app.appCleanup();
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

  void goto(BuildContext context, String route) {
    if (globals.app.routes.containsKey(route)) {
      if (route != globals.app.currentRoute) {
        globals.app.currentRoute = route;
        globals.app.floatingActionNotifier.value =
            HideableFloatingActionData(false);
        globals.app.routeNotifier.value = route;
      } else {
        //when same route
      }
    } else {
      //when route doesn't exist
    }
    Navigator.pop(context);
  }

  void refresh(BuildContext context) {
    goto(context, globals.app.currentRoute);
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
      valueListenable: globals.app.routeNotifier,
      builder: (_, newRoute, __) {
        ThemedPage Function(BuildContext)? builder =
            globals.app.routes[newRoute];
        if (builder == null) {
          builder = globals.app.routes['/'];
          globals.app.currentRoute = '/';
        } else {
          globals.app.currentRoute = newRoute;
        }

        return SlidingUpPanel(
          minHeight: 120,
          panel: PlayerMenu(),
          body: builder!(context),
          footer: Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColorLight,
            child: Row(
              //width: double.infinity,
              //child: Row(
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                Slider(
                  value: seeker,
                  onChanged: (value) {
                    //print('newVal: $value');
                    setState(() {
                      seeker = value;
                    });
                  },
                ),
              ],
              //),
            ),
          ),
        );
      },
    );
  }
}
