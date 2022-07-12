import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:test_project/widgets/flyout/flyoutItem.dart';
import '../../globals.dart' as globals;

class Flyout extends StatelessWidget {
  const Flyout({super.key});

  void navigate(BuildContext context, String route) {
    globals.app.navigation.goto(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark.withOpacity(0.8),
            ),
            height: 100,
            child: Center(
              child: Text(
                'Header',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: Theme.of(context).textTheme.headline4?.fontSize,
                ),
              ),
            ),
          ),
          FlyoutItem(
            icon: Icons.home,
            text: 'Home',
            onTapped: () => navigate(context, '/'),
          ),
          FlyoutItem(
            icon: Icons.music_note,
            text: 'Files',
            onTapped: () => navigate(context, '/files'),
          ),
          FlyoutItem(
              icon: Icons.close,
              text: 'Exit',
              onTapped: () => globals.app.closeApp(context))
        ], //drawer top
      ),
    );
  }
}
