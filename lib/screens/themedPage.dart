import 'package:flutter/material.dart';

import '../widgets/flyout/flyout.dart';

abstract class ThemedPage extends StatefulWidget {
  const ThemedPage({
    Key? key,
    required this.title,
    required this.themeNotifier,
  }) : super(key: key);

  final String title;
  final ValueNotifier<MaterialColor>? themeNotifier;

  Scaffold getScaffold(Widget? body, [Widget? floatingActionButton]) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      drawer: const Flyout(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
