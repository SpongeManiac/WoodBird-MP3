import 'package:flutter/material.dart';
import 'package:test_project/widgets/flyout/flyoutItem.dart';

class Flyout extends StatelessWidget {
  const Flyout({super.key});

  void navigate(BuildContext context, String route) {
    print(ModalRoute.of(context)?.settings.name);
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    } else {
      Navigator.pop(context);
    }
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
        ], //drawer top
      ),
    );
  }
}
