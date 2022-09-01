import 'dart:async';
import 'dart:io';
import 'dart:ui';
//import 'package:badges/badges.dart';
//import 'package:marquee/marquee.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/models/states/song/songData.dart';
import 'package:test_project/screens/CRUDPage.dart';
import 'package:test_project/widgets/artUri.dart';
import 'package:test_project/widgets/contextPopupButton.dart';
import '../models/AudioInterface.dart';
import '../models/contextItemTuple.dart';
import '../widgets/contextPopupButton.dart';
import '../widgets/appBar.dart';
import 'themedPage.dart';
import 'package:path/path.dart' as p;

class SongsPage extends ThemedPage {
  SongsPage({super.key, required super.title});

  @override
  State<StatefulWidget> createState() => _SongsPageState();

  @override
  AppBarData getDefaultAppBar() {
    print('getting def app bar');
    return AppBarData(
      title,
    );
  }
}

//

//

class _SongsPageState extends CRUDState<AudioSource> {
  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  Map<AudioSource, ContextPopupButton> songContexts =
      <AudioSource, ContextPopupButton>{};

  AudioInterface get interface => widget.app.audioInterface;

  List<AudioSource> get songs => widget.app.songsNotifier.value;
  set songs(List<AudioSource> newSongs) =>
      widget.app.songsNotifier.value = newSongs;
  //List<AudioSource> get queue => interface.queueNotifier.value.children;
  //set queue(queue) => interface.queueNotifier.value = queue;

  ValueNotifier<bool> loadingSongsNotifier = ValueNotifier<bool>(false);
  ValueNotifier<double?> loadingProgressNotifier = ValueNotifier<double?>(0);
  ValueNotifier<String> artUriNotifier = ValueNotifier<String>('');

  MediaItem get toEditTag {
    return AudioInterface.getTag(itemToEdit!);
  }

  TextEditingController newArtist = TextEditingController(text: '');
  TextEditingController newAlbum = TextEditingController(text: '');
  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

  ContextPopupButton getSongContext(AudioSource song) {
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
              List<MediaItem> selected = [];
              //List<MediaItem> selected = [];
              await Future.delayed(Duration(seconds: 0), () async {
                await SelectDialog.showModal<MediaItem>(context,
                    label: 'Select playlists to add song to.',
                    multipleSelectedValues: selected,
                    items: widget.app.songsNotifier.value
                        .map(AudioInterface.getTag)
                        .toList(), itemBuilder: (context, item, isSelected) {
                  return ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.artist ?? ''),
                    trailing: (isSelected ? Icon(Icons.check_rounded) : null),
                  );
                }, onMultipleItemsChange: (List<MediaItem> selectedSong) {
                  setState(() {
                    selected = selectedSong;
                  });
                });
              }).then((value) {
                print('selected: ${selected.length}');
              });
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
            await setUpdate(song);
          }),
          'Delete': ContextItemTuple(Icons.delete_rounded, () async {
            await delete(song);
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

  Future<void> songTapped(AudioSource song) async {
    await widget.app.audioInterface.add(song);
    var tag = AudioInterface.getTag(song);
    print('tapped ${tag.title}');
  }

  //set states
  @override
  Future<void> setRead() async {
    super.setRead();
    artUriNotifier.value = '';
    widget.setAndroidBack(() async {
      widget.app.navigation.goto(context, '/');
      return false;
    });
  }

  @override
  Future<void> setUpdate(AudioSource item) async {
    widget.setAndroidBack(() async {
      cancel();
      return false;
    });
    var tag = AudioInterface.getTag(item);
    var idx = int.tryParse(tag.id);
    // if(idx != null){

    // }
    itemToEdit = item;
    newName.text = tag.title;
    newArtist.text = tag.artist ?? '';
    var tagArtUri = tag.artUri.toString();
    print('tag arturi: $tagArtUri');
    newArt.text = tag.artUri == null ? '' : tagArtUri;
    artUriNotifier.value = newArt.text;
    //print('newArt: ${newArt.text}');
    state = ViewState.update;
  }

  @override
  Future<void> setDelete(AudioSource item) async {
    await cancel();
  }

  Future<String> getArt() async {
    var artDir = Directory(widget.app.artDir);
    if (!await artDir.exists()) {
      await artDir.create();
    }
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['png', 'jpg'],
      withData: false,
      withReadStream: true,
    );

    if (result != null && result.count == 1) {
      String? path = result.paths[0];
      if (path == null) return '';
      String base = p.basename(path);
      //var dir = p.join(songs, base);

      String ogPath = path;
      print('og path: $ogPath');
      File tempFile = File(ogPath);
      String newPath = p.join(artDir.path, base);
      File preCachedFile = File(newPath);
      //check if file already exists
      if (!await preCachedFile.exists()) {
        var cacheFile = await tempFile.rename(newPath);
        print('cachedFile path: ${cacheFile.path}');
      }
      //remove temp cache file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return preCachedFile.path;
    } else {
      print('No result or cancelled');
      return '';
    }
  }

  //crud ops
  @override
  Future<List<AudioSource?>> create() async {
    List<AudioSource> newSongs = [];
    var songsDir = Directory(widget.app.songsDir);
    if (!await songsDir.exists()) {
      await songsDir.create();
    }
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
      double fraction = (1.0 / result.count);
      print('songs: ${result.count}, fraction: $fraction');
      loadingProgressNotifier.value = fraction;
      for (var i = 0; i < result.count; i++) {
        String? path = result.paths[i];
        path ??= '-1';
        if (path == '-1') continue;
        String base = p.basename(path);
        //var dir = p.join(songs, base);

        String ogPath = result.paths[i]!;
        print('og path: $ogPath');
        var tempFile = File(ogPath);
        var newPath = p.join(songsDir.path, base);
        var preCacheFile = File(newPath);
        if (!await preCacheFile.exists()) {
          var cacheFile = await tempFile.rename(newPath);
          print('cachedFile path: ${cacheFile.path}');
        }
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        print('newPath: $newPath');
        print('base: $base');

        var split = base.split('.');
        String name = '';
        for (String part in split) {
          if (part != split.last) {
            name = '$name$part.';
          }
        }
        var ext = split.last;
        if (ext.length == 3 && (ext == 'mp3' || ext == 'm4a')) {
          name = name.substring(0, name.length - 1);
        } else {
          name = base;
        }
        print(name);
        print(ext);
        UriAudioSource songSource = AudioSource.uri(
            widget.app.getSongUri(widget.app.getSongCachePath(base)),
            tag: MediaItem(
              id: '-1',
              title: name,
              artist: '',
              album: '',
            ));
        newName.text = name;
        newArtist.text = 'unknown';
        newAlbum.text = '';
        newArt.text = '';
        await update(songSource);
        print('updated artist: ${(songSource.tag as MediaItem).artist}');
        //print(songSource);
        print('Adding: ${songSource.uri}');
        newSongs.add(songSource);
        //print('updating progress: ${loadingProgressNotifier.value}');
        loadingProgressNotifier.value = (i + 1) * fraction;
        //await Future.delayed(const Duration(milliseconds: 10));
      }
    } else {
      print('null result');
    }
    loadingSongsNotifier.value = false;
    loadingProgressNotifier.value = 0;
    return newSongs;
  }

  @override
  Future<AudioSource> update(AudioSource item) async {
    MediaItem tag = AudioInterface.getTag(item);
    print('updating ${tag.title} with id ${tag.id}');
    var newTag = MediaItem(
      id: tag.id,
      title: newName.text,
      artist: newArtist.text,
      album: newAlbum.text,
      artUri: Uri.parse(newArt.text),
    );

    var newSong = AudioSource.uri(
      (item as UriAudioSource).uri,
      tag: newTag,
    );
    //item = newSong;
    var tmp = List.of(songs);
    var newItem = SongData.fromSource(newSong);
    bool isNew =
        (newItem.id == null || !await widget.db.songExists(newItem.id!));
    print('updated song: ${newTag.title}, ${newTag.id}, ${newTag.artist}');
    //update song in db if it exists
    print('saving song changes to db');
    await newItem.saveData();
    //update newSong's ID
    newSong = newItem.source;
    if (isNew) {
      tmp.add(newSong);
    } else {
      tmp[tmp.indexOf(item)] = newSong;
    }
    songs = tmp;
    return newSong;
  }

  @override
  Future<void> delete(AudioSource item) async {
    MediaItem tag = (item as UriAudioSource).tag as MediaItem;
    print('tag: ${tag.id}');
    var tmp = List.of(songs);
    if (tmp.contains(item)) {
      print('song in song list, removing song ${tag.id}');
      var idx = int.tryParse(tag.id) ?? -1;
      if (idx < 0) {
        print('idx was nat valid for ${tag.title} with id: ${tag.id}');
        print('delete cancelled');
        return;
      }
      await widget.db.delSongData(
        SongDataDB(
            id: idx,
            artist: tag.artist ?? '',
            album: tag.album ?? '',
            title: tag.title,
            localPath: item.uri.path,
            art: tag.artUri == null ? '' : tag.artUri!.path),
      );
      tmp.remove(item);
      songs = tmp;
    } else {
      print('song not in list, delete failed');
    }
  }

  //views
  @override
  Widget createView(BuildContext context) {
    setRead();
    return readView(context);
  }

  @override
  Widget readView(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder<List<AudioSource>>(
          valueListenable: widget.app.songsNotifier,
          builder: (context, newSongs, _) {
            List<Widget> children = [
              ListTile(
                title: Text('Add Song(s)...'),
                trailing: Icon(
                  Icons.add_rounded,
                  color: Theme.of(context).primaryColorDark,
                ),
                onTap: () async {
                  await create();
                  setState(() {});
                },
              ),
            ];
            if (newSongs.isNotEmpty) {
              children.add(ListTile(
                title: const Text('Queue All'),
                trailing: Icon(
                  Icons.auto_awesome_motion_rounded,
                  color: Theme.of(context).primaryColorDark,
                ),
                onTap: () {
                  interface.addToQueue(songs);
                },
              ));
            }
            children.add(
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await widget.app.loadSongs();
                    setState(() {});
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: newSongs.length,
                    itemBuilder: (context, index) {
                      AudioSource song = newSongs[index];
                      MediaItem tag = AudioInterface.getTag(song);
                      var songContextBtn = getSongContext(song);
                      print('song art: ${tag.artUri}');
                      return ListTile(
                        enabled: true,
                        onTap: () {
                          //print('tap');
                          songTapped(song);
                        },
                        onLongPress: () {
                          //print('long press');
                          //print(widget.songContexts[song]);
                          songContexts[song]!.showDialog();
                        },
                        leading: ArtUri(tag.artUri ?? Uri.parse('')),
                        title: Text(tag.title),
                        subtitle: Text(tag.artist ?? 'empty'),
                        trailing: songContextBtn,
                      );
                    },
                  ),
                ),
              ),
            );
            print('got songs: ${newSongs.toList()}');
            return Column(
              children: children,
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: loadingSongsNotifier,
          builder: (context, loadingSongs, _) {
            print('loading songs: $loadingSongs');
            return Visibility(
              visible: loadingSongs,
              child: ValueListenableBuilder<double?>(
                valueListenable: loadingProgressNotifier,
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
  }

  @override
  Widget updateView(BuildContext context) {
    if (itemToEdit == null) {
      return Text('Invalid song');
    }
    var song = itemToEdit!;
    print(
        'editing ${toEditTag.title}, path: ${(song as UriAudioSource).uri.toFilePath()}');
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              //height: Theme.of(context).textTheme.headlineLar!.fontSize,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Text('Editing:'),
                    Expanded(
                      child: Text(
                        toEditTag.title,
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
            Divider(),
            Text('${(song as UriAudioSource).uri}'),
            Divider(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  newName.text = toEditTag.title;
                  newArtist.text = toEditTag.artist ?? '';
                  newArt.text =
                      toEditTag.artUri == null ? '' : toEditTag.artUri!.path;
                },
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Name'),
                      subtitle: TextFormField(
                        controller: newName,
                      ),
                    ),
                    ListTile(
                      title: Text('Artist'),
                      subtitle: TextFormField(
                        controller: newAlbum,
                      ),
                    ),
                    ListTile(
                      title: Text('Album'),
                      subtitle: TextFormField(
                        controller: newAlbum,
                      ),
                    ),
                    ListTile(
                      title: const Text('Song Art'),
                      subtitle: TextFormField(
                        controller: newArt,
                        onChanged: (text) async {
                          artUriNotifier.value = text;
                        },
                        onFieldSubmitted: (text) async {
                          //print('Text changed: $text');
                          artUriNotifier.value = text;
                          //newArt.text;
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.folder_open_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          String artPath = await getArt();
                          print('Art path: $artPath');
                          newArt.text = artPath;
                        },
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      constraints: BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 200,
                      ),
                      child: ValueListenableBuilder<String>(
                        valueListenable: artUriNotifier,
                        builder: ((context, newUri, child) {
                          print('Notifier updated: $newUri');
                          return ArtUri(Uri.parse(newUri));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await update(song);
                    await setRead();
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
                  onPressed: () async {
                    print('Cancel tapped');
                    print(newName.text);
                    print(toEditTag.id);
                    await cancel();
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

  @override
  Widget deleteView(BuildContext context) {
    setRead();
    return readView(context);
  }
}
