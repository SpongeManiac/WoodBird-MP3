import 'package:flutter/cupertino.dart';
import 'package:test_project/widgets/hideableFloatingAction.dart';

class ActionButtonLayout extends StatelessWidget {
  ActionButtonLayout({this.body, this.actionButton});
  Widget? body;
  Widget? actionButton;
  @override
  Widget build(BuildContext context) {
    body ??= const Center(child: Text('Default Body'));
    actionButton ??= const HideableFloatingAction();
    return Stack(
      children: [
        body!,
        Positioned(
          bottom: 120,
          right: 20,
          child: actionButton!,
        ),
      ],
    );
  }
}
