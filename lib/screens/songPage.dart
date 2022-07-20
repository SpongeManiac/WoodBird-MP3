import 'dart:io';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' show basename;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:test_project/models/states/song/SongData.dart';
import 'package:test_project/widgets/contextPopupButton.dart';

import '../widgets/appBar.dart';
import 'themedPage.dart';

class SongsPage extends ThemedPage {
  SongsPage({
    Key? key,
    required super.title,
  }) : super(key: key);

  Map<SongData, ContextPopupButton> songContexts =
      <SongData, ContextPopupButton>{};

  @override
  State<SongsPage> createState() => _SongsPageState();

  @override
  Future<void> saveState() async {
    return;
  }

  Future<void> addSong() async {
    print('going to add song');
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowMultiple: true, allowedExtensions: ['mp3']);
    if (result != null) {
      print('got ${result.count} file(s)');
      List<SongData> list = List.from(app.songsNotifier.value);
      for (String? path in result.paths) {
        path ??= '-1';
        if (path == '-1') continue;
        File file = File(path);
        String base = basename(path);
        var split = base.split('.');
        var name = split.first;
        var ext = split.last;
        print(name);
        print(ext);
        //create song data
        SongData song = SongData('unknown', name, path);
        song.saveData();
        list.add(song);
        app.songsNotifier.value = list;
      }
    } else {
      print('null result');
    }
  }

  ContextPopupButton getSongContext(SongData song) {
    var popup = ContextPopupButton(
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) {
          Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
            'Add to queue': ContextItemTuple(Icons.queue_music_rounded),
            'Add to playlist...': ContextItemTuple(
              Icons.playlist_add,
              () async {
                await addSong();
              },
            ),
            'Add to album...': ContextItemTuple(Icons.album),
            'Play single': ContextItemTuple(
              Icons.play_arrow,
              () async {
                app.playerInterface.playSingle(song);
              },
            ),
            'Edit': ContextItemTuple(Icons.edit_rounded),
            'Delete': ContextItemTuple(Icons.delete),
          };

          List<PopupMenuItem<String>> list = [];

          for (String val in choices.keys) {
            var choice = choices[val];
            list.add(
              PopupMenuItem(
                  onTap: choice!.onPress,
                  child: Row(
                    children: [
                      Icon(
                        choice.icon,
                        color: Theme.of(context).primaryColor,
                      ),
                      Expanded(
                        child: Text(
                          val,
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  )),
            );
          }

          return list;
        });
    // void Function() tmp = () {
    //   print('showing dialog');
    //   popup.showDialog();
    // };

    songContexts[song] = popup;
    return popup;
  }

  @override
  AppBarData getDefaultAppBar() {
    print('getting def app bar');
    return AppBarData(title, <Widget>[
      PopupMenuButton<String>(
          //key: _key?,
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
              'Add Song': ContextItemTuple(
                Icons.folder,
                () async {
                  await addSong();
                },
              ),
              'Test 2': ContextItemTuple(Icons.bug_report),
            };

            List<PopupMenuItem<String>> list = [];

            for (String val in choices.keys) {
              list.add(
                PopupMenuItem(
                    onTap: choices[val]!.onPress,
                    child: Row(
                      children: [
                        Icon(
                          choices[val]!.icon,
                          color: Theme.of(context).primaryColor,
                        ),
                        Expanded(
                          child: Text(
                            val,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    )),
              );
            }

            return list;
          }),
    ]);
  }

  Future<void> songTapped(SongData song) async {
    await app.playerInterface.playSingle(song);
    print('playing');
  }
}

class _SongsPageState extends State<SongsPage> {
  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.app.songsNotifier,
      builder: (context, List<SongData> newSongs, _) {
        print('got songs: ${newSongs.toList()}');
        return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: newSongs.length,
                  itemBuilder: ((context, index) {
                    SongData song = newSongs[index];

                    var songContextBtn = widget.getSongContext(song);
                    return ListTile(
                      enabled: true,
                      onTap: () {
                        //print('tap');
                        widget.songTapped(song);
                      },
                      onLongPress: () {
                        //print('long press');
                        //print(widget.songContexts[song]);
                        widget.songContexts[song]!.showDialog();
                      },
                      title: Text(song.name),
                      subtitle: Text(song.artist),
                      trailing: songContextBtn,
                    );
                  }),
                )));
      },
    );
  }
}

class ContextItemTuple {
  ContextItemTuple(this.icon, [this.onPress, this.onLongPress]);
  IconData icon;
  Future<void> Function()? onPress;
  Future<void> Function()? onLongPress;
}
