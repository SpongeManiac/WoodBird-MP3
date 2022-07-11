import 'package:flutter/material.dart';
import '../globals.dart' as globals;

class HideableFloatingAction extends StatelessWidget {
  const HideableFloatingAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HideableFloatingActionData>(
        valueListenable: globals.app.floatingActionNotifier,
        builder: (context, data, _) {
          //setPress();
          if (data.action == null) {
            data.visible = false;
          }
          return Visibility(
            visible: data.visible,
            child: FloatingActionButton(
              onPressed: data.action,
              child: data.child,
            ),
          );
        });
  }
}

class HideableFloatingActionData {
  HideableFloatingActionData(this.visible, [this.action, this.child]);

  bool visible;
  void Function()? action;
  Widget? child;
}
