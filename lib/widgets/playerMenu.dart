import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerMenu extends StatefulWidget {
  PlayerMenu({super.key});

  @override
  State<StatefulWidget> createState() => _PlayerMenuState();
}

class _PlayerMenuState extends State<PlayerMenu> {
  _PlayerMenuState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.drag_handle_rounded,
              color: Theme.of(context).primaryColor,
              size: 40,
            ),
            Text('Body Text'),
          ],
        ),
      ),
    );
  }
}
