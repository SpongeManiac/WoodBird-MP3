import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../globals.dart' show app;

class ShuffleModeButton extends StatelessWidget {
  ShuffleModeButton({super.key, this.color, this.size});

  Color? color;
  double? size;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: app.audioInterface.player.shuffleModeEnabledStream,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        bool shuffleEnabled = snapshot.data ?? false;
        if (shuffleEnabled) {
          return IconButton(
            icon: Icon(Icons.shuffle_on_rounded, color: color),
            iconSize: size,
            onPressed: () {
              app.audioInterface.player.setShuffleModeEnabled(false);
            },
          );
        } else {
          return IconButton(
            icon: Icon(Icons.shuffle_rounded, color: color),
            iconSize: size,
            onPressed: () {
              app.audioInterface.player.setShuffleModeEnabled(true);
              app.audioInterface.player.shuffle();
            },
          );
        }
      },
    );
  }
}
