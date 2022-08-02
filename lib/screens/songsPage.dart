import 'dart:io';
import 'dart:ui';
//import 'package:badges/badges.dart';
//import 'package:marquee/marquee.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path/path.dart' show basename;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/models/states/song/songData.dart';
import 'package:test_project/widgets/contextPopupButton.dart';
import '../models/AudioInterface.dart';
import '../models/contextItemTuple.dart';
import '../widgets/contextPopupButton.dart';
import '../widgets/appBar.dart';
import 'themedPage.dart';

class SongsPage extends ThemedPage {
  SongsPage({
    super.key,
    required super.title,
  }) {
    editingNotifier = ValueNotifier<AudioSource?>(null);
  }

  Map<AudioSource, ContextPopupButton> songContexts =
      <AudioSource, ContextPopupButton>{};

  AudioInterface get interface => app.audioInterface;

  List<AudioSource> get songs => app.songsNotifier.value;
  set songs(songs) => app.songsNotifier.value = songs;
  //List<AudioSource> get queue => interface.queueNotifier.value.children;
  set queue(queue) => interface.queueNotifier.value = queue;

  ValueNotifier<bool> loadingSongsNotifier = ValueNotifier<bool>(false);
  ValueNotifier<double?> loadingProgressNotifier = ValueNotifier<double?>(0);

  late ValueNotifier<AudioSource?> editingNotifier;

  AudioSource? get songToEdit {
    return editingNotifier.value;
  }

  MediaItem get source {
    return AudioInterface.getTag(songToEdit!);
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
    loadingProgressNotifier.value = null;
    loadingSongsNotifier.value = true;
    print('going to add song');
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['mp3'],
      withData: false,
      withReadStream: true,
    );
    if (result != null && result.count > 0) {
      print('got ${result.count} file(s)');
      List<AudioSource> list = List.from(songs);
      double fraction = (1.0 / result.count);
      print('songs: ${result.count}, fraction: $fraction');
      loadingProgressNotifier.value = fraction;
      for (var i = 0; i < result.count; i++) {
        String? path = result.paths[i];
        path ??= '-1';
        if (path == '-1') continue;
        print('path: ${result.files[i].path}');
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
        await song.saveData();
        var tag = AudioInterface.getTag(song.source);
        print(tag.title);
        print(tag.artist);
        print(tag.album);
        print(tag.id);
        list.add(song.source);
        print('updating progress: ${loadingProgressNotifier.value}');
        loadingProgressNotifier.value = (i + 1) * fraction;
        await Future.delayed(const Duration(milliseconds: 10));
      }
      songs = list;
    } else {
      print('null result');
    }
    loadingSongsNotifier.value = false;
    loadingProgressNotifier.value = 0;
  }

  Widget editSong(BuildContext context) {
    if (songToEdit == null) {
      return Text('Invalid song');
    }
    //var song = songToEdit!;

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
                        source.title,
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
                  newName.text = source.title;
                  newArtist.text = source.artist ?? '';
                  newArt.text =
                      source.artUri == null ? '' : source.artUri!.path;
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
                        newName.text = source.title;
                        newArtist.text = source.artist ?? '';
                        newArt.text =
                            source.artUri == null ? '' : source.artUri!.path;
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
                    updateSong(songToEdit!);
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

  Future<void> updateSong(AudioSource song) async {
    MediaItem tag = AudioInterface.getTag(song);
    var newSong = AudioSource.uri(
      (song as UriAudioSource).uri,
      tag: MediaItem(id: tag.id, title: newName.text, artist: newArtist.text),
    );
    //update song in db if it exists
    print('saving song changes to db');
    SongData.fromSource(newSong).saveData();
    List<AudioSource> tmp = List.from(songs);
    tmp[tmp.indexOf(song)] = newSong;
    songs = tmp;
    // if (interface.getCurrent() == song) {
    //   interface.playlist.add(audioSource) = newSong;
    // }
    editingNotifier.value = null;
  }

  Future<void> delSong(AudioSource song) async {
    MediaItem source = (song as UriAudioSource).tag as MediaItem;
    var tmp = List.of(songs);
    if (tmp.contains(song)) {
      print('song in song list, removing song ${source.id}');
      await db.delSongData(
        SongDataDB(
            id: int.parse(source.id),
            artist: source.artist ?? '',
            name: source.title,
            localPath: song.uri.path,
            art: source.artUri == null ? '' : source.artUri!.path),
      );
      tmp.remove(song);
      songs = tmp;
    } else {
      print('song not in list, delete failed');
    }
  }

  ContextPopupButton getSongContext(BuildContext context, AudioSource song) {
    var popup = ContextPopupButton(
      icon:
          //Badge(
          //badgeContent: Text('${song.id}'), child:
          Icon(
        Icons.more_vert,
        color: Theme.of(context).primaryColor,
      ),
      //),
      itemBuilder: (context) {
        Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
          'Add to queue': ContextItemTuple(
            Icons.queue_music_rounded,
            () async {
              //await app.audioInterface.addToQueue(song);
            },
          ),
          'Add to playlist...': ContextItemTuple(
            Icons.playlist_add_rounded,
            () async {
              //avoid dialog being closed after choosing option
              await Future.delayed(
                Duration(seconds: 0),
                () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Hello!'),
                        content: Text('More hellos!'),
                      );
                    },
                  );
                  //Navigator.of(context).pop();

                  // return Container(
                  //   height: 100,
                  //   width: 100,
                  //   padding: EdgeInsets.all(10),
                  //   child: Column(
                  //     children: [
                  //       Text('This is an alert. Select a choice.'),
                  //       ListView(
                  //         children: [
                  //           ListTile(
                  //             title: Text('Hello!'),
                  //           ),
                  //           ListTile(
                  //             title: Text('Goodbye!'),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // );
                },
              );
              print('alerted');
            },
          ),
          'Add to album...': ContextItemTuple(Icons.album),
          'Play single': ContextItemTuple(
            Icons.play_arrow,
            () async {
              //app.audioInterface.playSingle(song);
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
                  ),
                ],
              ),
            ),
          );
        }

        return list;
      },
    );

    songContexts[song] = popup;
    return popup;
  }

  @override
  AppBarData getDefaultAppBar() {
    print('getting def app bar');
    return AppBarData(
      title,
      <Widget>[
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
                  ),
                ),
              );
            }

            return list;
          },
        ),
      ],
    );
  }

  Future<void> songTapped(AudioSource song) async {
    await app.audioInterface.addToQueue(song);
    var tag = AudioInterface.getTag(song);
    print('tapped ${tag.title}');
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
    return ValueListenableBuilder<AudioSource?>(
      valueListenable: widget.editingNotifier,
      builder: ((context, songToEdit, _) {
        if (songToEdit == null) {
          return Stack(
            children: [
              ValueListenableBuilder<List<AudioSource>>(
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
                            itemBuilder: (context, index) {
                              AudioSource song = newSongs[index];
                              MediaItem tag = AudioInterface.getTag(song);
                              var songContextBtn =
                                  widget.getSongContext(context, song);
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
                                title: Text(tag.title),
                                subtitle: Text(tag.artist ?? 'empty'),
                                trailing: songContextBtn,
                              );
                            },
                          )));
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: widget.loadingSongsNotifier,
                builder: (context, loadingSongs, _) {
                  print('loading songs: $loadingSongs');
                  return Visibility(
                    visible: loadingSongs,
                    child: ValueListenableBuilder<double?>(
                      valueListenable: widget.loadingProgressNotifier,
                      builder: (context, progress, _) {
                        print('progres: $progress');
                        return Center(
                          child: CircularProgressIndicator(value: progress),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        } else {
          return widget.editSong(context);
        }
      }),
    );
  }
}
