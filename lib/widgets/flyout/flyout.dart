import 'package:flutter/material.dart';
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
              color: Theme.of(context).primaryColor,
              height: MediaQuery.of(context).padding.top + 100,
              width: double.infinity,
              child: Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: const Center(
                    child: Text(
                  'Woodbird MP3',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
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
                ], //drawer top
              ),
            ),
            FlyoutItem(
              icon: Icons.close_rounded,
              text: 'Exit',
              onTapped: () => app.closeApp(context),
            ),
          ],
        ),
      ),
    );
  }
}
