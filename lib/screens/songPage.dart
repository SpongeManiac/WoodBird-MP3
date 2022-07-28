import 'dart:io';
import 'dart:ui';
import 'package:badges/badges.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart' show basename;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:test_project/models/states/song/SongData.dart';
import 'package:test_project/widgets/contextPopupButton.dart';

import '../models/AudioInterface.dart';
import '../widgets/appBar.dart';
import 'themedPage.dart';

class SongsPage extends ThemedPage {
  SongsPage({
    Key? key,
    required super.title,
  }) {
    editingNotifier = ValueNotifier<SongData?>(null);
  }

  Map<SongData, ContextPopupButton> songContexts =
      <SongData, ContextPopupButton>{};

  AudioInterface get interface => app.audioInterface;

  List<SongData> get songs => app.songsNotifier.value;
  set songs(songs) => app.songsNotifier.value = songs;
  List<SongData> get queue => interface.queueNotifier.value;

  late ValueNotifier<SongData?> editingNotifier;

  SongData? get songToEdit {
    return editingNotifier.value;
  }

  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newArtist = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

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
      List<SongData> list = List.from(songs);
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
        SongData song = SongData(
          artist: 'unknown',
          name: name,
          localPath: path,
        );
        song.saveData();
        list.add(song);
        songs = list;
      }
    } else {
      print('null result');
    }
  }

  Widget editSong(BuildContext context) {
    if (songToEdit == null) {
      return Text('Invalid song');
    }
    var song = songToEdit!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: Theme.of(context).textTheme.headlineMedium!.fontSize,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Text('Editing:'),
                    Expanded(
                      child: Text(
                        song.name,
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 10),
                      //   child: Marquee(text: '${song.name} '),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  newName.text = song.name;
                  newArtist.text = song.artist;
                  newArt.text = song.art;
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        newName.text = song.name;
                        newArtist.text = song.artist;
                        newArt.text = song.art;
                        switch (index) {
                          case 0:
                            return ListTile(
                              leading: Container(
                                width: 80,
                                child: const Text('Name:'),
                              ),
                              title: TextFormField(
                                controller: newName,
                              ),
                            );
                          case 1:
                            return ListTile(
                              leading: Container(
                                width: 80,
                                child: const Text('Artist:'),
                              ),
                              title: TextFormField(
                                controller: newArtist,
                              ),
                            );
                          case 2:
                            return ListTile(
                              leading: Container(
                                width: 80,
                                child: const Text('Cover Art:'),
                              ),
                              title: TextFormField(
                                controller: newArt,
                              ),
                            );
                        }
                        return ListTile(title: Text('invalid index'));
                      }),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    updateSong(song);
                  },
                  child: Text('Save'),
                  // style: ButtonStyle(
                  //   backgroundColor: Theme.of(context).,
                  // ),
                ),
                Container(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    editingNotifier.value = null;
                  },
                  child: Text(
                    'cancel',
                    style: TextStyle(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateSong(SongData song) async {
    song.name = newName.text;
    song.artist = newArtist.text;
    song.art = newArt.text;
    //song.saveData();
    //List<SongData> tmp = List.from(songs);
    List<SongData> q = List.from(app.audioInterface.queueNotifier.value);
    //ValueNotifier<SongData> currentPlaying = app.audioInterface.currentNotifier!;
    // if (tmp.contains(song)) {
    //   print('found match in songs, updating song');
    // } else {
    //   print('checking songs by path');
    //   for (var i = 0; i < tmp.length; i++) {
    //     var idx = tmp[i];
    //     if (idx.localPath == song.localPath) {
    //       print('found match in songs, updating song');

    //     } else {
    //       print('no matches found, save failed.');
    //       return;
    //     }
    //   }
    // }

    // if (q.contains(song)) {
    //   print('found match in q, updating song');
    //   q[q.indexOf(song)] = song.copy();
    // } else {
    //   print('checking q by path/id');
    //   for (var i = 0; i < q.length; i++) {
    //     var idx = q[i];
    //     if (idx.localPath == song.localPath) {
    //       print('found match by path in q, updating song');
    //       idx = song;
    //     } else if (idx.id != null && idx.id! > -1 && idx.id == song.id) {
    //       print('found match by id in q, updating song');
    //       idx = song;
    //     } else {
    //       print('no matches found, q update failed.');
    //     }
    //   }
    // }
    //update song in db if it exists
    print('saving song changes to db');
    song.saveData();
    //songs = tmp;
    if (app.audioInterface.current == song) {
      app.audioInterface.currentNotifier!.value = song.copy();
    }
    editingNotifier.value = null;
  }

  Future<void> delSong(SongData song) async {
    var tmp = List.of(songs);
    if (tmp.contains(song)) {
      print('song in song list, removing song ${song.id}');
      await db.delSongData(song.getEntry());
      tmp.remove(song);
      songs = tmp;
    } else {
      print('song not in list, delete failed');
    }
  }

  ContextPopupButton getSongContext(SongData song) {
    var popup = ContextPopupButton(
        icon: Badge(
            badgeContent: Text('${song.id}'), child: Icon(Icons.more_vert)),
        itemBuilder: (context) {
          Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
            'Add to queue': ContextItemTuple(
              Icons.queue_music_rounded,
              () async {
                await app.audioInterface.addToQueue(song);
              },
            ),
            'Add to playlist...': ContextItemTuple(
              Icons.playlist_add_rounded,
              () async {
                await addSong();
              },
            ),
            'Add to album...': ContextItemTuple(Icons.album),
            'Play single': ContextItemTuple(
              Icons.play_arrow,
              () async {
                app.audioInterface.playSingle(song);
              },
            ),
            'Edit': ContextItemTuple(Icons.edit_rounded, () async {
              editingNotifier.value = song;
            }),
            'Delete': ContextItemTuple(Icons.delete_rounded, () async {
              await delSong(song);
            }),
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
    await app.audioInterface.addToQueue(song);
    print('tapped ${song.name}');
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
    return ValueListenableBuilder<SongData?>(
      valueListenable: widget.editingNotifier,
      builder: ((context, songToEdit, _) {
        if (songToEdit == null) {
          return ValueListenableBuilder<List<SongData>>(
            valueListenable: widget.app.songsNotifier,
            builder: (context, newSongs, _) {
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
        } else {
          return widget.editSong(context);
        }
      }),
    );
  }
}

class ContextItemTuple {
  ContextItemTuple(this.icon, [this.onPress, this.onLongPress]);
  IconData icon;
  Future<void> Function()? onPress;
  Future<void> Function()? onLongPress;
}
