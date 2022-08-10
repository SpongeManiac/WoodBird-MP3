import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:marquee/marquee.dart';
//import 'package:test_project/models/AudioInterface_old.bak';
import 'package:test_project/screens/songsPage.dart';
import 'package:test_project/widgets/loopModeButton.dart';
import 'package:test_project/widgets/shuffleModeButton.dart';
import '../globals.dart' show app;
import 'package:test_project/widgets/playPauseButton.dart';

import '../models/AudioInterface.dart';
import '../models/contextItemTuple.dart';
import '../models/states/song/songData.dart';
import 'contextPopupButton.dart';
import 'seekBar.dart';

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

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      app.controls.value = [];
    });
  }

  void moveControl(int oldIndex, int newIndex) {
    if (oldIndex != newIndex) {
      bool oldLarger = oldIndex > newIndex;
      //newIndex--;
      if (!oldLarger) {
        //print('adjusting newIndex: $newIndex');
        newIndex--;
        //print('new: $newIndex');
      }
      //print('moving $oldIndex to $newIndex');
      var tmp = app.controls.value;
      var maxLength = 5;
      //print('max length: $maxLength');
      int control = tmp[oldIndex];
      if (newIndex >= maxLength) {
        //print('moving song to end. Just adding');
        tmp.add(control);
      } else {
        if (oldLarger) {
          //print('new oldIndex: $oldIndex');
          oldIndex++;
          //print('inserting @ $newIndex');
          //print('before:');
          //printList(tmp);
          tmp.insert(newIndex, control);
          //print('after:');
          //printList(tmp);
        } else {
          //print('shifting');
          newIndex++;
          //print('inserting @ $newIndex');
          //print('before:');
          //printList(tmp);
          tmp.insert(newIndex, control);
          //print('after:');
          //printList(tmp);
        }
      }
      print('removing old');
      tmp.removeAt(oldIndex);
      app.controls.value = tmp;
    }
  }

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

  void moveButton(int currentIdx, int newIdx) {
    if (currentIdx < newIdx) {
      newIdx--;
    }
    print('moving $currentIdx to $newIdx');
    moveControl(currentIdx, newIdx);
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
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: StreamBuilder<int?>(
                                  stream: widget
                                      .interface.player.currentIndexStream,
                                  builder: (context, newSong) {
                                    var idx = newSong.data ?? 0;
                                    //print('idx is $idx');
                                    AudioSource source;
                                    if (newQueue == 0) {
                                      source =
                                          widget.interface.emptyQueue.source;
                                    } else if (idx == newQueue) {
                                      source =
                                          widget.interface.playlist[idx - 1];
                                    } else {
                                      source = widget.interface.playlist[idx];
                                    }
                                    MediaItem tag =
                                        AudioInterface.getTag(source);
                                    print((source as UriAudioSource)
                                        .uri
                                        .toFilePath());
                                    return Marquee(
                                      text: '${tag.title} - ${tag.artist} | ',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                    );
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
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withOpacity(.2),
                                        spreadRadius: 4,
                                        blurRadius: 5,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.5),
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: ValueListenableBuilder(
                                      valueListenable: app.controls,
                                      builder:
                                          ((context, List<int> controls, _) {
                                        return ReorderableListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          onReorder: ((oldIndex, newIndex) {
                                            moveControl(oldIndex, newIndex);
                                          }),
                                          itemCount: 5,
                                          itemBuilder: ((context, index) {
                                            switch (controls[index]) {
                                              case 0: // prev
                                                return IconButton(
                                                  key: const Key('prev'),
                                                  icon: Icon(
                                                    Icons.skip_previous_rounded,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  //iconSize: 20,
                                                  onPressed: () async {
                                                    await widget
                                                        .interface.player
                                                        .seekToPrevious();
                                                  },
                                                );
                                              case 1: //pause/play
                                                return PlayPauseButton(
                                                  key: const Key('play'),
                                                  //size: 20,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                );
                                              case 2: //next
                                                return IconButton(
                                                  key: const Key('next'),
                                                  icon: Icon(
                                                    Icons.skip_next_rounded,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  //iconSize: 20,
                                                  onPressed: () async {
                                                    await widget
                                                        .interface.player
                                                        .seekToNext();
                                                  },
                                                );
                                              case 3: //shuffle mode
                                                return ShuffleModeButton(
                                                  key: const Key('shuffle'),
                                                  //size: 20,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                );
                                              case 4: //loop mode
                                                return LoopModeButton(
                                                  key: const Key('loop'),
                                                  //size: 20,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                );
                                              default:
                                                return IconButton(
                                                  key: Key('unknown$index'),
                                                  onPressed: () {},
                                                  icon: Icon(Icons
                                                      .question_mark_rounded),
                                                );
                                            }
                                          }),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: StreamBuilder<PositionData>(
                                stream: widget.interface.positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;
                                  return SeekBar(
                                    duration:
                                        positionData?.duration ?? Duration.zero,
                                    position:
                                        positionData?.position ?? Duration.zero,
                                    bufferedPosition:
                                        positionData?.bufferedPosition ??
                                            Duration.zero,
                                    onChangeEnd: widget.interface.player.seek,
                                  );
                                },
                              ),
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
                      StreamBuilder(
                          stream: widget.interface.player.currentIndexStream,
                          builder: ((context, AsyncSnapshot<int?> snapshot) {
                            int currentPlaying = snapshot.data ?? -1;
                            return ReorderableListView.builder(
                                onReorder: (int oldIndex, int newIndex) {
                                  widget.interface.move(oldIndex, newIndex);
                                },
                                itemCount: newQueue,
                                itemBuilder: (((context, index) {
                                  bool isCurrent = index == currentPlaying;
                                  AudioSource song =
                                      widget.interface.playlist[index];
                                  MediaItem tag = AudioInterface.getTag(song);
                                  var songContextBtn =
                                      getSongContext(context, song);

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
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      tag.artist ?? '',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    trailing: songContextBtn,
                                  );
                                })));
                          })),
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
