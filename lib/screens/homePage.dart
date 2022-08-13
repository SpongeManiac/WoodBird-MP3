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
  AppBarData getDefaultAppBar() {
    print('getting def app bar');
    return AppBarData(title, <Widget>[
      PopupMenuButton<String>(
          //key: _key?,
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
              'Add Song': ContextItemTuple(
                Icons.folder,
                () async {
                  //await addSong();
                },
              ),
              'Test 2': ContextItemTuple(Icons.bug_report),
            };

            List<PopupMenuItem<String>> list = [];

            for (String val in choices.keys) {
              list.add(
                PopupMenuItem(
                    onTap: choices[val]!.onPress,
                    child: Row(
                      children: [
                        Icon(
                          choices[val]!.icon,
                          color: Theme.of(context).primaryColor,
                        ),
                        Expanded(
                          child: Text(
                            val,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    )),
              );
            }

            return list;
          }),
    ]);
  }

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
