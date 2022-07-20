import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../globals.dart' show app;
import 'package:test_project/widgets/PlayPauseButton.dart';

import '../models/states/song/SongData.dart';

class PlayerMenu extends StatefulWidget {
  PlayerMenu({super.key});

  @override
  State<StatefulWidget> createState() => _PlayerMenuState();
}

class _PlayerMenuState extends State<PlayerMenu> {
  _PlayerMenuState();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SongData>(
      valueListenable: app.playerInterface.currentSongNotifier,
      builder: (context, newSong, _) {
        return Center(
          child: Container(
            color: Theme.of(context).primaryColorLight,
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Marquee(
                              text: '${newSong.name} - ${newSong.artist} | ',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 40,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.skip_previous_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {},
                            ),
                            PlayPauseButton(),
                            IconButton(
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.5),
                            //size: ,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
