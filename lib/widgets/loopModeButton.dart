import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../globals.dart' show app;

class LoopModeButton extends StatelessWidget {
  LoopModeButton({super.key, this.color, this.size});

  Color? color;
  double? size;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: app.audioInterface.player.loopModeStream,
      builder: (context, AsyncSnapshot<LoopMode> snapshot) {
        LoopMode loopMode = snapshot.data ?? LoopMode.all;
        switch (loopMode) {
          case LoopMode.off:
            return IconButton(
              icon: Icon(Icons.repeat_rounded, color: color),
              iconSize: size,
              onPressed: () {
                app.audioInterface.player.setLoopMode(LoopMode.all);
              },
            );
          case LoopMode.one:
            return IconButton(
              icon: Icon(Icons.repeat_one_on_rounded, color: color),
              iconSize: size,
              onPressed: () {
                app.audioInterface.player.setLoopMode(LoopMode.off);
              },
            );
          case LoopMode.all:
            return IconButton(
              icon: Icon(Icons.repeat_on_rounded, color: color),
              iconSize: size,
              onPressed: () {
                app.audioInterface.player.setLoopMode(LoopMode.one);
              },
            );
        }
      },
    );
  }
}
