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
      //backgroundColor: Theme.of(context).primaryColorLight,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Theme.of(context).primaryColorDark.withOpacity(0.8),
            height: MediaQuery.of(context).padding.top + 100,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: Text(
                  'Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Theme.of(context).textTheme.headline4?.fontSize,
                  ),
                ),
              ),

              //),
            ),
          ),
          FlyoutItem(
            icon: Icons.home_rounded,
            text: 'Home',
            onTapped: () => navigate(context, '/'),
          ),
          FlyoutItem(
            icon: Icons.music_note_rounded,
            text: 'Files',
            onTapped: () => navigate(context, '/songs'),
          ),
          FlyoutItem(
            icon: Icons.queue_music_rounded,
            text: 'Playlists',
            onTapped: () => navigate(context, '/playlists'),
          ),
          FlyoutItem(
              icon: Icons.close_rounded,
              text: 'Exit',
              onTapped: () => globals.app.closeApp(context))
        ], //drawer top
      ),
    );
  }
}
