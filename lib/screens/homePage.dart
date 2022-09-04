import 'package:flutter/material.dart';
import 'package:test_project/screens/themedPage.dart';

import '../models/contextItemTuple.dart';
import '../widgets/appBar.dart';
import '../widgets/contextPopupButton.dart';

class HomePage extends ThemedPage {
  HomePage({super.key, required super.title});

  @override
  State<StatefulWidget> createState() => _HomePageState();

  @override
  void initState(BuildContext context) {
    super.initState(context);
    setAndroidBack(() async {
      return await app.navigation.exitDialog(context);
    });
  }
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    //init action button
    //widget.initFloatingAction(_incrementCounter, const Icon(Icons.add));
    //init this state
    widget.initState(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Hello!'));
  }
}
