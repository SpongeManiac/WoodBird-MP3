import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../widgets/hideableFloatingAction.dart';
import 'themedPage.dart';
import 'homePage.dart';
import 'songPage.dart';

class PageNav extends StatefulWidget {
  const PageNav({
    Key? key,
  }) : super(key: key);

  void goto(BuildContext context, String route) {
    if (globals.routes.containsKey(route)) {
      if (route != globals.currentRoute) {
        globals.currentRoute = route;
        globals.floatingActionNotifier.value =
            HideableFloatingActionData(false);
        //change current route
        globals.routeNotifier.value = route;
      } else {
        //when same route
      }
    } else {
      //when route doesn't exist
    }
    Navigator.pop(context);
  }

  void refresh(BuildContext context) {
    goto(context, globals.currentRoute);
  }

  @override
  State<PageNav> createState() => _PageNavState();
}

class _PageNavState extends State<PageNav> {
  _PageNavState() : super();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globals.routeNotifier,
      builder: (_, newRoute, __) {
        WidgetBuilder? builder = globals.routes[newRoute];
        if (builder == null) {
          builder = globals.routes['/'];
          globals.currentRoute = '/';
        } else {
          globals.currentRoute = newRoute;
        }
        return builder!(context);
      },
    );
  }
}
