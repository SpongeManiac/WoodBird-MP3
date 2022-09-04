import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart';
//import 'package:test_project/models/AudioInterface_old.bak';
import 'package:test_project/widgets/artUri.dart';
import 'package:test_project/widgets/loopModeButton.dart';
import 'package:test_project/widgets/shuffleModeButton.dart';
import '../globals.dart' show app;
import 'package:test_project/widgets/playPauseButton.dart';

import '../models/AudioInterface.dart';
import '../models/contextItemTuple.dart';
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
      var tmpState = app.homePageStateNotifier.value;
      tmpState.controls = tmp;
      app.homePageStateNotifier.value = tmpState;
      app.controls.value = tmp;
      app.saveHomeState();
    }
  }

  ContextPopupButton getSongContext(
      BuildContext context, AudioSource song, int index) {
    var popup = ContextPopupButton(
      icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
      itemBuilder: (context) {
        Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
          'Remove from queue':
              ContextItemTuple(Icons.playlist_remove_rounded, () async {
            await widget.interface.remove(song);
          }),
          'Play': ContextItemTuple(Icons.play_arrow_rounded, () async {
            await widget.interface.setCurrent(index);
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
          'Remove All': ContextItemTuple(Icons.low_priority_rounded, () async {
            await widget.interface.removeAll();
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
                Icon(choice.icon, color: Theme.of(context).primaryColorDark),
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
        if (widget.interface.playlist.length == 0) {
          newQueue = 0;
        }
        return Center(
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                Container(
                  color: Color.alphaBlend(Colors.white.withOpacity(0.2),
                      Theme.of(context).primaryColorLight),
                  child: ValueListenableBuilder<bool>(
                      valueListenable: app.swapTrackBar,
                      builder: ((context, swap, child) {
                        var seekBar = Container(
                          height: 40,
                          child: Row(
                            children: [
                              Expanded(
                                child: StreamBuilder<PositionData>(
                                  stream: widget.interface.positionDataStream,
                                  builder: (context, snapshot) {
                                    final positionData = snapshot.data;
                                    return SeekBar(
                                      duration: positionData?.duration ??
                                          Duration.zero,
                                      position: positionData?.position ??
                                          Duration.zero,
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
                        );

                        var controls = Container(
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
                                      var idx = newSong.data ?? -1;
                                      //print('idx is $idx');
                                      AudioSource source;
                                      if (idx == -1) {
                                        if (newQueue > 0) {
                                          source = widget.interface.playlist[0];
                                        } else {
                                          source = widget
                                              .interface.emptyQueue.source;
                                        }
                                      } else if (newQueue == 0) {
                                        source =
                                            widget.interface.emptyQueue.source;
                                      } else {
                                        source = widget.interface.playlist[idx];
                                      }
                                      // } else if (idx == newQueue) {
                                      //   source =
                                      //       widget.interface.playlist[idx - 1];
                                      // } else {
                                      //   source = widget.interface.playlist[idx];
                                      // }
                                      MediaItem tag =
                                          AudioInterface.getTag(source);
                                      // print((source as UriAudioSource)
                                      //     .uri
                                      //     .toFilePath());
                                      return Marquee(
                                        text: '${tag.title} - ${tag.artist} | ',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontWeight: FontWeight.bold),
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
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
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
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        width: 2.0,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      child: ValueListenableBuilder<List<int>>(
                                        valueListenable: app.controls,
                                        builder:
                                            ((context, List<int> controls, _) {
                                          //print('controls: ${controls.length}');
                                          return ReorderableListView.builder(
                                            shrinkWrap: true,
                                            buildDefaultDragHandles: false,
                                            scrollDirection: Axis.horizontal,
                                            onReorder: ((oldIndex, newIndex) {
                                              moveControl(oldIndex, newIndex);
                                            }),
                                            itemCount: controls.length,
                                            itemBuilder: ((context, index) {
                                              // print(
                                              //     'loading control: ${controls[index]}');
                                              switch (controls[index]) {
                                                case 0: // prev
                                                  return ReorderableDelayedDragStartListener(
                                                    index: index,
                                                    key: const Key('prev'),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .skip_previous_rounded,
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                      ),
                                                      //iconSize: 20,
                                                      onPressed: () async {
                                                        await widget
                                                            .interface.player
                                                            .seekToPrevious();
                                                      },
                                                    ),
                                                  );
                                                case 1: //pause/play
                                                  return ReorderableDelayedDragStartListener(
                                                    index: index,
                                                    key: const Key('play'),
                                                    child: PlayPauseButton(
                                                      //size: 20,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                  );
                                                case 2: //next
                                                  return ReorderableDelayedDragStartListener(
                                                    index: index,
                                                    key: const Key('next'),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.skip_next_rounded,
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                      ),
                                                      //iconSize: 20,
                                                      onPressed: () async {
                                                        await widget
                                                            .interface.player
                                                            .seekToNext();
                                                      },
                                                    ),
                                                  );
                                                case 3: //shuffle mode
                                                  return ReorderableDelayedDragStartListener(
                                                    index: index,
                                                    key: const Key('shuffle'),
                                                    child: ShuffleModeButton(
                                                      //size: 20,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                  );
                                                case 4: //loop mode
                                                  return ReorderableDelayedDragStartListener(
                                                    index: index,
                                                    key: const Key('loop'),
                                                    child: LoopModeButton(
                                                      //size: 20,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                  );
                                                default:
                                                  return ReorderableDelayedDragStartListener(
                                                    key: Key('unknown$index'),
                                                    index: index,
                                                    child: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons
                                                            .question_mark_rounded,
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                      ),
                                                    ),
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
                        );
                        return swap
                            ? Column(
                                children: [seekBar, controls],
                              )
                            : Column(
                                children: [controls, seekBar],
                              );
                      })),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: widget.interface.player.currentIndexStream,
                    builder: (context, AsyncSnapshot<int?> snapshot) {
                      int currentPlaying = snapshot.data ?? -1;
                      var noSongUri = Uri.parse('');
                      AudioSource? currentSong;
                      MediaItem? currentSongTag;
                      if (currentPlaying != -1 && newQueue != 0) {
                        currentSong = widget.interface.playlist[currentPlaying];
                        currentSongTag = AudioInterface.getTag(currentSong);
                      }
                      print('loading song queu in media menu');
                      return Stack(
                        children: [
                          //Expanded(
                          //child:
                          Center(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    //width: double.infinity,
                                    //height: double.infinity,
                                    //mainAxisAlignment: MainAxisAlignment.center,
                                    color: Colors.transparent,
                                    child: ArtUri(
                                      newQueue > 0 && currentPlaying > -1
                                          ? currentSongTag!.artUri ?? noSongUri
                                          : noSongUri,
                                      padding: 20,
                                      opacity: .3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            onReorder: (int oldIndex, int newIndex) {
                              widget.interface.move(oldIndex, newIndex);
                            },
                            itemCount: newQueue,
                            itemBuilder: (context, index) {
                              var isCurrent = index == currentPlaying;
                              AudioSource song =
                                  widget.interface.playlist[index];
                              MediaItem tag = AudioInterface.getTag(song);
                              var songContextBtn =
                                  getSongContext(context, song, index);
                              if (isCurrent) {
                                return ReorderableDelayedDragStartListener(
                                  index: index,
                                  key: ValueKey(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        width: 2,
                                        style: BorderStyle.solid,
                                        strokeAlign: StrokeAlign.inside,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () async {
                                        await widget.interface
                                            .setCurrent(index);
                                      },
                                      title: Text(
                                        tag.title,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        tag.artist ?? '',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: songContextBtn,
                                    ),
                                  ),
                                );
                              } else {
                                return ReorderableDelayedDragStartListener(
                                  index: index,
                                  key: ValueKey(index),
                                  child: ListTile(
                                    onTap: () async {
                                      await widget.interface.setCurrent(index);
                                    },
                                    title: Text(
                                      tag.title,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                    subtitle: Text(
                                      tag.artist ?? '',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                    trailing: songContextBtn,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
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
