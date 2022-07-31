import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:test_project/widgets/flyout/flyoutItem.dart';
import '../../globals.dart' show app;
import '../../screens/themedPage.dart';

class Flyout extends StatelessWidget {
  const Flyout({super.key});

  Map<String, ThemedPage Function(BuildContext)> get routes => app.routes;

  void navigate(BuildContext context, String route) {
    app.navigation.goto(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColorDark.withOpacity(0.8),
              height: MediaQuery.of(context).padding.top + 100,
            ),
            Expanded(
              child: Column(
                //padding: EdgeInsets.zero,
                children: [
                  FlyoutItem(
                    icon: Icons.home_rounded,
                    text: 'Home',
                    onTapped: () => navigate(context, '/'),
                  ),
                  FlyoutItem(
                    icon: Icons.music_note_rounded,
                    text: 'Songs',
                    onTapped: () => navigate(context, '/songs'),
                  ),
                  FlyoutItem(
                    icon: Icons.queue_music_rounded,
                    text: 'Playlists',
                    onTapped: () => navigate(context, '/playlists'),
                  ),
                  FlyoutItem(
                    icon: Icons.settings_rounded,
                    text: 'Settings',
                    onTapped: () => navigate(context, '/settings'),
                  ),
                  Expanded(child: Container()),
                  FlyoutItem(
                      icon: Icons.close_rounded,
                      text: 'Exit',
                      onTapped: () => app.closeApp(context))
                ], //drawer top
              ),
            ),
          ],
        ),
      ),
    );
  }
}
