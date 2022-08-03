import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:marquee/marquee.dart';
//import 'package:test_project/models/AudioInterface_old.bak';
import 'package:test_project/screens/songsPage.dart';
import '../globals.dart' show app;
import 'package:test_project/widgets/PlayPauseButton.dart';

import '../models/AudioInterface.dart';
import '../models/contextItemTuple.dart';
import '../models/states/song/songData.dart';
import 'contextPopupButton.dart';

class PlayerMenu extends StatefulWidget {
  PlayerMenu({super.key});

  AudioInterface get interface => app.audioInterface;

  Map<AudioSource, ContextPopupButton> songContexts =
      <AudioSource, ContextPopupButton>{};

  @override
  State<StatefulWidget> createState() => _PlayerMenuState();
}

class _PlayerMenuState extends State<PlayerMenu> {
  _PlayerMenuState();

  ContextPopupButton getSongContext(BuildContext context, AudioSource song) {
    var popup = ContextPopupButton(
      icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
      itemBuilder: (context) {
        Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
          'Remove from queue':
              ContextItemTuple(Icons.playlist_remove_rounded, () async {
            await widget.interface.remove(song);
          }),
          'Play': ContextItemTuple(Icons.play_arrow_rounded, () async {
            await widget.interface.setCurrent(song);
            setState(() {});
          }),
          'Move Up': ContextItemTuple(Icons.move_up_rounded, () async {
            await widget.interface.moveUp(song);
            setState(() {});
          }),
          'Move Down': ContextItemTuple(Icons.move_down_rounded, () async {
            await widget.interface.moveDown(song);
            setState(() {});
          }),
          'Move to top':
              ContextItemTuple(Icons.format_list_numbered_rounded, () async {
            await widget.interface.moveTop(song);
            setState(() {});
          }),
          'Move to bottom':
              ContextItemTuple(Icons.low_priority_rounded, () async {
            await widget.interface.moveEnd(song);
            setState(() {});
          }),
        };

        List<PopupMenuItem<String>> list = [];

        for (String val in choices.keys) {
          var choice = choices[val];
          list.add(PopupMenuItem(
            onTap: choice!.onPress,
            child: Row(
              children: [
                Icon(choice.icon, color: Theme.of(context).primaryColor),
                Expanded(
                  child: Text(
                    val,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ));
        }

        return list;
      },
    );
    widget.songContexts[song] = popup;
    return popup;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.interface.queueNotifier,
      builder: (context, newQueue, _) {
        return Center(
          child: Container(
            color: Theme.of(context).primaryColorLight,
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.2),
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: StreamBuilder<int?>(
                            stream: widget.interface.player.currentIndexStream,
                            builder: (context, newSong) {
                              var idx = newSong.data ?? -1;
                              //print('idx is $idx');
                              AudioSource source;
                              if (newQueue == 0) {
                                source = widget.interface.emptyQueue.source;
                              } else {
                                source = widget.interface.playlist[idx];
                              }
                              MediaItem tag = AudioInterface.getTag(source);

                              return Marquee(
                                text: '${tag.title} - ${tag.artist} | ',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
                              );
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: Theme.of(context).primaryColorDark,
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
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () async {
                                await widget.interface.player.seekToPrevious();
                              },
                            ),
                            PlayPauseButton(),
                            IconButton(
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                await widget.interface.player.seekToNext();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      //Expanded(
                      //child:
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Icon(
                                Icons.music_note_rounded,
                                color: Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //),
                      // ),
                      ReorderableListView.builder(
                          onReorder: (int oldIndex, int newIndex) {
                            widget.interface.move(oldIndex, newIndex);
                          },
                          itemCount: newQueue,
                          itemBuilder: (((context, index) {
                            if (index ==
                                (widget.interface.player.currentIndex ?? -1)) {
                              //this item is currently playing
                            }
                            AudioSource song = widget.interface.playlist[index];
                            MediaItem tag = AudioInterface.getTag(song);
                            var songContextBtn = getSongContext(context, song);
                            return ListTile(
                              key: ValueKey(index),
                              enabled: true,
                              onTap: () async {
                                await widget.interface.setCurrent(song);
                              },
                              // onLongPress: () async {
                              //   widget.songContexts[song]!.showDialog();
                              // },
                              title: Text(
                                tag.title,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              subtitle: Text(
                                tag.artist ?? '',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              trailing: songContextBtn,
                            );
                          }))),
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
