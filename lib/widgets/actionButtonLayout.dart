import 'package:flutter/cupertino.dart';
import 'package:woodbirdmp3/widgets/hideableFloatingAction.dart';

class ActionButtonLayout extends StatelessWidget {
  ActionButtonLayout({super.key, this.actionButton, required this.child});
  Widget? actionButton;
  Widget child;
  @override
  Widget build(BuildContext context) {
    actionButton ??= const HideableFloatingAction();
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 20,
          right: 20,
          child: actionButton!,
        ),
      ],
    );
  }
}
