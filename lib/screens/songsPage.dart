import 'dart:async';
import 'dart:io';
//import 'package:badges/badges.dart';
//import 'package:marquee/marquee.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/models/states/song/songData.dart';
import 'package:test_project/platform_specific/device.dart';
import 'package:test_project/screens/CRUDPage.dart';
import 'package:test_project/widgets/artUri.dart';
import 'package:test_project/widgets/contextPopupButton.dart';
import '../models/AudioInterface.dart';
import '../models/contextItemTuple.dart';
import 'themedPage.dart';
import 'package:path/path.dart' as p;

class SongsPage extends ThemedPage {
  SongsPage({super.key, required super.title});

  @override
  State<StatefulWidget> createState() => _SongsPageState();

  @override
  void initState(BuildContext context) {
    // TODO: implement initState
    super.initState(context);
    setAndroidBack(
      context,
      () async {
        await app.closeApp(context);
        return false;
      },
      Icons.close_rounded,
    );
  }
}

//

//

class _SongsPageState extends CRUDState<AudioSource> {
  Map<AudioSource, ContextPopupButton> songContexts = <AudioSource, ContextPopupButton>{};

  AudioInterface get interface => widget.app.audioInterface;

  List<AudioSource> get songs => widget.app.songsNotifier.value;
  set songs(List<AudioSource> newSongs) => widget.app.songsNotifier.value = newSongs;

  ValueNotifier<String> artUriNotifier = ValueNotifier<String>('');

  MediaItem get toEditTag {
    return AudioInterface.getTag(itemToEdit!);
  }

  TextEditingController newArtist = TextEditingController(text: '');
  TextEditingController newAlbum = TextEditingController(text: '');
  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget get songForm => Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                controller: newName,
                validator: (value) => validateTitle(value),
                minLines: 1,
                maxLength: 128,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Artist',
                ),
                controller: newArtist,
                validator: (value) => validateTitle(value),
                minLines: 1,
                maxLength: 128,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Album',
                ),
                controller: newAlbum,
                validator: (value) => validateTitle(value),
                minLines: 1,
                maxLength: 128,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  icon: IconButton(
                    icon: const Icon(Icons.image_search_rounded),
                    onPressed: () async {
                      widget.app.loadingProgressNotifier.value = null;
                      widget.app.loadingNotifier.value = true;
                      var path = await (widget.app as DesktopApp).getArt();
                      if (!path.hasEmptyPath) {
                        setState(() {
                          newArt.text = path.toString();
                          artUriNotifier.value = path.toString();
                        });
                      }
                      widget.app.loadingNotifier.value = false;
                      widget.app.loadingProgressNotifier.value = null;
                    },
                  ),
                  labelText: 'Art',
                  hintText: 'Image URL/Path',
                ),
                controller: newArt,
                validator: (value) => validateDesc(value),
                onChanged: (value) => artUriNotifier.value = value,
                minLines: 1,
                maxLength: 1024,
              ),
              ValueListenableBuilder(
                valueListenable: artUriNotifier,
                builder: (context, newArtPath, child) {
                  return ArtUri(
                    Uri.parse(artUriNotifier.value),
                    maxSize: 100,
                  );
                },
              ),
              // TextFormField(
              //   keyboardType: TextInputType.text,
              //   textInputAction: TextInputAction.done,
              //   decoration: InputDecoration(
              //     icon: Container(
              //       height: 56,
              //       width: 56,
              //       child: IconButton(
              //         iconSize: 56.0,
              //         color: Theme.of(context).primaryColor,
              //         icon: ArtUri(Uri.parse(newArt.text)),
              //         onPressed: () async {
              //           widget.app.loadingProgressNotifier.value = null;
              //           widget.app.loadingNotifier.value = true;
              //           var path = await (widget.app as DesktopApp).getArt();
              //           if (!path.hasEmptyPath) {
              //             setState(() {
              //               newArt.text = path.toString();
              //               ////print('New Path: ${path.toString()}');
              //             });
              //           }
              //           widget.app.loadingNotifier.value = false;
              //           widget.app.loadingProgressNotifier.value = null;
              //         },
              //       ),
              //     ),
              //     labelText: 'Art',
              //     hintText: 'Image URL/Path',
              //   ),
              //   controller: newArt,
              //   validator: (value) => validateDesc(value),
              //   maxLength: 1024,
              // ),
            ],
          ),
        ),
      );

  String? validateTitle(String? val) {
    val = val ?? '';
    if (val.isEmpty || val.trim().isEmpty) return 'Please enter some text.';
    return null;
  }

  String? validateDesc(String? val) {
    val = val ?? '';
    return null;
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  ContextPopupButton getSongContext(AudioSource song) {
    ////print('getting song popup context');
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
              await Future.delayed(const Duration(seconds: 0), () async {
                await SelectDialog.showModal<MediaItem>(context,
                    label: 'Select playlists to add song to.',
                    multipleSelectedValues: selected,
                    items: widget.app.songsNotifier.value.map(AudioInterface.getTag).toList(),
                    itemBuilder: (context, item, isSelected) {
                  return ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.artist ?? ''),
                    trailing: (isSelected ? const Icon(Icons.check_rounded) : null),
                  );
                }, onMultipleItemsChange: (List<MediaItem> selectedSong) {
                  setState(() {
                    selected = selectedSong;
                  });
                });
              }).then((value) {
                ////print('selected: ${selected.length}');
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
    ////print('tapped ${tag.title}');
  }

  //set states

  @override
  Future<void> setRead([_]) async {
    super.setRead();
    artUriNotifier.value = '';
    widget.setAndroidBack(
      context,
      () async {
        await widget.app.closeApp(context);
        return false;
      },
      Icons.close_rounded,
    );
  }

  @override
  Future<void> setUpdate(AudioSource item, [_]) async {
    await super.setUpdate(item);
    var tag = AudioInterface.getTag(item);
    newName.text = tag.title;
    newArtist.text = tag.artist ?? '';
    var tagArtUri = tag.artUri.toString();
    ////print('tag arturi: $tagArtUri');
    newArt.text = tag.artUri == null ? '' : tagArtUri;
    artUriNotifier.value = newArt.text;
    ////print('newArt: ${newArt.text}');
    state = ViewState.update;
  }

  // @override
  // Future<void> setDelete(AudioSource item) async {
  //   await cancel();
  // }

  //crud ops
  @override
  Future<List<AudioSource?>> create() async {
    List<AudioSource> newSongs = [];
    var songsDir = Directory(widget.app.songsDir);
    if (!await songsDir.exists()) {
      await songsDir.create();
    }
    widget.app.loadingProgressNotifier.value = null;
    widget.app.loadingNotifier.value = true;
    ////print('going to add song');
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['mp3'],
      withData: false,
      withReadStream: true,
    );
    if (result != null && result.count > 0) {
      double fraction = (1.0 / result.count);
      ////print('songs: ${result.count}, fraction: $fraction');
      widget.app.loadingProgressNotifier.value = fraction;
      for (var i = 0; i < result.count; i++) {
        String? path = result.paths[i];
        path ??= '-1';
        if (path == '-1') continue;
        String base = p.basename(path);
        //var dir = p.join(songs, base);

        String ogPath = result.paths[i]!;
        //print('og path: $ogPath');
        var tempFile = File(ogPath);
        var newPath = p.join(songsDir.path, base);
        var preCacheFile = File(newPath);
        if (!await preCacheFile.exists()) {
          var cacheFile = await tempFile.rename(newPath);
          //print('cachedFile path: ${cacheFile.path}');
        }
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        //print('newPath: $newPath');
        //print('base: $base');

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
        //print(name);
        //print(ext);
        UriAudioSource songSource = AudioSource.uri(widget.app.getSongUri(widget.app.getSongCachePath(base)),
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
        //print('updated artist: ${(songSource.tag as MediaItem).artist}');
        ////print(songSource);
        //print('Adding: ${songSource.uri}');
        newSongs.add(songSource);
        ////print('updating progress: ${loadingProgressNotifier.value}');
        widget.app.loadingProgressNotifier.value = (i + 1) * fraction;
        //await Future.delayed(const Duration(milliseconds: 10));
      }
    } else {
      //print('null result');
    }
    widget.app.loadingNotifier.value = false;
    widget.app.loadingProgressNotifier.value = null;
    return newSongs;
  }

  @override
  Future<AudioSource> update(AudioSource item) async {
    var tag = AudioInterface.getTag(item);
    //check if newArt is different
    var artUri = tag.artUri ?? Uri.parse('');
    var path = artUri.toString();
    if (newArt.text != artUri.toString() && path.contains('file:///')) {
      //delete old photo if it exists
      var file = File.fromUri(artUri);
      if (await file.exists()) {
        //old image exists, delete it
        await file.delete();
        print('Deleted old photo from cache');
      }
    }
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
    bool isNew = (newItem.id == null || !await widget.db.songExists(newItem.id!));
    //print('updated song: ${newTag.title}, ${newTag.id}, ${newTag.artist}');
    //update song in db if it exists
    //print('saving song changes to db');
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
    //print('tag: ${tag.id}');
    var tmp = List.of(songs);
    if (tmp.contains(item)) {
      //print('song in song list, removing song ${tag.id}');
      var idx = int.tryParse(tag.id) ?? -1;
      if (idx < 0) {
        //print('idx was nat valid for ${tag.title} with id: ${tag.id}');
        //print('delete cancelled');
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
      //print('song not in list, delete failed');
    }
  }

  //views
  @override
  Widget createViewBuilder(BuildContext context) {
    setRead();
    return readViewBuilder(context);
  }

  @override
  Widget readViewBuilder(BuildContext context) {
    return ValueListenableBuilder<List<AudioSource>>(
      valueListenable: widget.app.songsNotifier,
      builder: (context, newSongs, _) {
        return Center(
          child: Column(
            children: [
              ListTile(
                title: const Text('Add Song(s)...'),
                trailing: Icon(
                  Icons.add_rounded,
                  color: Theme.of(context).primaryColorDark,
                ),
                onTap: () async {
                  await create();
                  setState(() {});
                },
              ),
              Visibility(
                visible: newSongs.isNotEmpty,
                child: ListTile(
                  title: const Text('Queue All'),
                  trailing: Icon(
                    Icons.auto_awesome_motion_rounded,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onTap: () {
                    interface.addToQueue(songs);
                  },
                ),
              ),
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
                      //print('song art: ${tag.artUri}');
                      return ListTile(
                        enabled: true,
                        onTap: () {
                          ////print('tap');
                          songTapped(song);
                        },
                        onLongPress: () {
                          ////print('long press');
                          ////print(widget.songContexts[song]);
                          songContexts[song]!.showDialog();
                        },
                        leading: ArtUri(
                          tag.artUri ?? Uri.parse(''),
                          maxSize: 48,
                        ),
                        title: Text(tag.title),
                        subtitle: Text(tag.artist ?? 'empty'),
                        trailing: songContextBtn,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget updateViewBuilder(BuildContext context) {
    if (itemToEdit == null) {
      return const Text('Invalid song');
    }
    var song = itemToEdit!;
    //print('editing ${toEditTag.title}, path: ${(song as UriAudioSource).uri.toFilePath()}');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              //height: Theme.of(context).textTheme.headlineLar!.fontSize,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Text('Editing:'),
                    Expanded(
                      child: Text(
                        toEditTag.title,
                        style: Theme.of(context).textTheme.titleLarge,
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
                  newName.text = toEditTag.title;
                  newArtist.text = toEditTag.artist ?? '';
                  newArt.text = toEditTag.artUri == null ? '' : toEditTag.artUri!.path;
                },
                child: ListView(
                  children: [
                    songForm,
                    Text('${(song as UriAudioSource).uri}'),
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
                  child: const Text('Save'),
                  // style: ButtonStyle(
                  //   backgroundColor: Theme.of(context).,
                  // ),
                ),
                Container(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    ////print('Cancel tapped');
                    ////print(newName.text);
                    ////print(toEditTag.id);
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
  Widget deleteViewBuilder(BuildContext context) {
    setRead();
    return readViewBuilder(context);
  }
}
