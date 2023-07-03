import 'package:flutter/material.dart';
import 'package:woodbirdmp3/screens/themedPage.dart';


class HomePage extends ThemedPage {
  HomePage({super.key, required super.title});

  @override
  State<StatefulWidget> createState() => _HomePageState();

  @override
  void initState(BuildContext context) {
    super.initState(context);
    setAndroidBack(context, () async {
      return await app.navigation.exitDialog(context);
    }, Icons.close_rounded);
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
    return const Center(child: Text('Hello!'));
  }
}
