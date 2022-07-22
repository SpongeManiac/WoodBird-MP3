import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../globals.dart' show app;

class PlayPauseButton extends StatelessWidget {
  PlayPauseButton({super.key});

  Future<void> togglePlaying() async {
    await app.audioInterface.togglePlay();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: app.audioInterface.playingNotifier,
      builder: (context, value, _) {
        print('playing: $value');
        var color = Theme.of(context).primaryColor;
        return IconButton(
          icon: value
              ? Icon(
                  Icons.pause_rounded,
                  color: color,
                )
              : Icon(
                  Icons.play_arrow_rounded,
                  color: color,
                ),
          onPressed: togglePlaying,
        );
        //return super.build(context);
      },
    );
    //return super.build(context);
  }
}
