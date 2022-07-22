import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:test_project/models/AudioInterface.dart';
import 'package:test_project/screens/songPage.dart';
import '../globals.dart' show app;
import 'package:test_project/widgets/PlayPauseButton.dart';

import '../models/states/song/SongData.dart';
import 'contextPopupButton.dart';

class PlayerMenu extends StatefulWidget {
  PlayerMenu({super.key});

  AudioInterface get interface => app.audioInterface;

  Map<SongData, ContextPopupButton> songContexts =
      <SongData, ContextPopupButton>{};

  ContextPopupButton getSongContext(BuildContext context, SongData song) {
    var popup = ContextPopupButton(
      icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
      itemBuilder: (context) {
        Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
          'Remove from queue':
              ContextItemTuple(Icons.playlist_remove_rounded, () async {
            await interface.removeFromQueue(song);
          }),
          'Play': ContextItemTuple(Icons.play_arrow_rounded, () async {
            await interface.setCurrentCont(song);
          }),
          'Move Up': ContextItemTuple(Icons.move_up_rounded, () async {
            await interface.moveUp(song);
          }),
          'Move Down': ContextItemTuple(Icons.move_down_rounded, () async {
            await interface.moveDown(song);
          }),
          'Move to top':
              ContextItemTuple(Icons.format_list_numbered_rounded, () async {
            interface.moveToTop(song);
          }),
          'Move to bottom':
              ContextItemTuple(Icons.low_priority_rounded, () async {
            await interface.moveToEnd(song);
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
    songContexts[song] = popup;
    return popup;
  }

  @override
  State<StatefulWidget> createState() => _PlayerMenuState();
}

class _PlayerMenuState extends State<PlayerMenu> {
  _PlayerMenuState();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SongData>>(
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
                          child: ValueListenableBuilder<SongData>(
                            valueListenable:
                                widget.interface.currentNotifier ??=
                                    ValueNotifier(widget.interface.emptyQueue),
                            builder: (context, newSong, _) {
                              return Marquee(
                                  text:
                                      '${newSong.name} - ${newSong.artist} | ',
                                  style: TextStyle(color: Colors.white));
                            },
                          ),
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
                              onPressed: () async {
                                await widget.interface.playPrev();
                              },
                            ),
                            PlayPauseButton(),
                            IconButton(
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                await widget.interface.playNext();
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
                          itemCount: newQueue.length,
                          itemBuilder: (((context, index) {
                            SongData song = newQueue[index];
                            var songContextBtn =
                                widget.getSongContext(context, song);
                            return ListTile(
                              key: ValueKey(index),
                              enabled: true,
                              onTap: () async {
                                await widget.interface.setCurrentCont(song);
                              },
                              // onLongPress: () async {
                              //   widget.songContexts[song]!.showDialog();
                              // },
                              title: Text(
                                song.name,
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                song.artist,
                                style: TextStyle(color: Colors.white),
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
