import 'dart:io';
import 'dart:ui';

import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:marquee/marquee.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:path/path.dart' as p;

import '../database/database.dart';
import '../models/AudioInterface.dart';
import '../models/contextItemTuple.dart';
import '../models/states/album/albumData.dart';
import '../models/states/song/songData.dart';
import '../widgets/appBar.dart';
import '../widgets/artUri.dart';
import '../widgets/contextPopupButton.dart';
import 'CRUDPage.dart';
import 'themedPage.dart';

class AlbumsPage extends ThemedPage {
  AlbumsPage({super.key, required super.title});

  @override
  AppBarData getDefaultAppBar() {
    return AppBarData(
      title,
    );
  }

  @override
  State<StatefulWidget> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends CRUDState<AlbumData> {
  ValueNotifier<List<MediaItem>> songs = ValueNotifier(<MediaItem>[]);
  ValueNotifier<String> artUriNotifier = ValueNotifier<String>('');

  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newArtist = TextEditingController(text: '');
  TextEditingController newDescription = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

  bool formExpanded = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget get albumForm => Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                controller: newName,
                validator: (value) => validateTitle(value),
                maxLength: 128,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Artist',
                ),
                controller: newArtist,
                validator: (value) => validateTitle(value),
                maxLength: 128,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                controller: newDescription,
                validator: (value) => validateDesc(value),
                maxLines: 3,
                maxLength: 1024,
              ),
              TextFormField(
                decoration: InputDecoration(
                  icon: Container(
                    height: 56,
                    width: 56,
                    child: ArtUri(Uri.parse(newArt.text)),
                  ),
                  labelText: 'Art',
                ),
                controller: newArt,
                //validator: (value) => validateDesc(value),
                maxLines: 2,
                maxLength: 1024,
              ),
            ],
          ),
        ),
      );

  Map<AlbumData, ContextPopupButton> albumContexts =
      <AlbumData, ContextPopupButton>{};

  List<AlbumData> get albums {
    return widget.app.albumsNotifier.value;
  }

  set albums(albums) => widget.app.albumsNotifier.value = albums;

  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  String? validateTitle(String? val) {
    val = val ?? '';
    if (val.isEmpty || val.trim().isEmpty) return 'Please enter some text.';
    return null;
  }

  String? validateDesc(String? val) {
    val = val ?? '';
    return null;
  }

  Future<void> setAlbumSongs() async {
    if (itemToEdit == null) return;
    List<MediaItem> tmp = [];
    List<SongDataDB> songsDB = await widget.db.getAlbumSongs(itemToEdit!);

    for (var song in songsDB) {
      tmp.add(AudioInterface.getTag(SongData.fromDB(song).source));
    }
    songs.value = tmp;
  }

  ContextPopupButton getAlbumContext(BuildContext context, AlbumData album) {
    var popup = ContextPopupButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).primaryColor,
      ),
      itemBuilder: (context) {
        Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
          'Set queue': ContextItemTuple(
            Icons.queue_music_rounded,
            () async {
              List<AudioSource> songs = (await widget.db.getAlbumSongs(album))
                  .map((s) => SongData.fromDB(s).source)
                  .toList();
              await widget.app.audioInterface.setQueue(songs);
            },
          ),
          'Add to queue': ContextItemTuple(
            Icons.playlist_add_rounded,
            () async {
              List<AudioSource> songs = (await widget.db.getAlbumSongs(album))
                  .map((s) => SongData.fromDB(s).source)
                  .toList();
              await widget.app.audioInterface.addToQueue(songs);
            },
          ),
          'Edit': ContextItemTuple(Icons.edit_rounded, () async {
            await setUpdate(album);
          }),
          'Delete': ContextItemTuple(Icons.delete_rounded, () async {
            await delete(album);
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

    albumContexts[album] = popup;
    return popup;
  }

  ContextPopupButton getSongContext(
      BuildContext context, AlbumData album, MediaItem song) {
    var popup = ContextPopupButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).primaryColor,
      ),
      itemBuilder: (context) {
        Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
          'Remove': ContextItemTuple(
            Icons.close,
            () async {
              var tmp = List.of(songs.value);
              int songId = int.tryParse(song.id) ?? -1;
              if (tmp.contains(song) &&
                  songId > -1 &&
                  await widget.db.delAlbumSong(
                        album.getEntry(),
                        (await widget.db.getSongData(songId))!,
                      ) >
                      0) {
                tmp.remove(song);
                songs.value = tmp;
                setState(() {
                  for (var s in songs.value) {
                    print('song relations:');
                    print(s.title);
                  }
                });
              }
            },
          ),
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

    albumContexts[album] = popup;
    return popup;
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

  //set states
  @override
  Future<void> setCreate() async {
    newName.text = '';
    newArtist.text = '';
    newDescription.text = '';
    newArt.text = '';
    artUriNotifier.value = '';
    state = ViewState.create;
  }

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
  Future<void> setUpdate(AlbumData item) async {
    print('switching to update');
    // if (item.id != null) {
    //   print('editing ${item.name} - ${item.id}');
    // }
    widget.setAndroidBack(() async {
      cancel();
      return false;
    });
    itemToEdit = item;
    newName.text = itemToEdit!.title;
    newArtist.text = itemToEdit!.artist;
    newDescription.text = itemToEdit!.description;
    newArt.text = itemToEdit!.art;
    artUriNotifier.value = newArt.text;
    await setAlbumSongs();
    state = ViewState.update;
  }

  @override
  Future<void> setDelete(AlbumData item) async {
    print('switching to delete');
    state = ViewState.delete;
  }

  //crud ops
  @override
  Future<List<AlbumData?>> create() async {
    var data = AlbumData(title: '', artist: '');
    await update(data);
    return [data];
  }

  @override
  Future<AlbumData> update(AlbumData item) async {
    item.title = newName.text;
    item.artist = newArtist.text;
    item.description = newDescription.text;
    item.art = newArt.text;
    var tmp = List.of(albums);
    print('saving album changes to db');
    bool isNew = (item.id == null || !await widget.db.albumExists(item.id!));
    await item.saveData();
    if (isNew) {
      tmp.add(item);
    } else {
      tmp[tmp.indexOf(item)] = item;
    }
    albums = tmp;
    return item;
  }

  @override
  Future<void> delete(AlbumData item) async {
    var tmp = List.of(albums);
    if (albums.contains(item)) {
      await widget.db.delAlbumData(item.getEntry());
      tmp.remove(item);
      albums = tmp;
    } else {
      print('album not in list, delete failed');
    }
  }

  Future<void> deleteSong(MediaItem song) async {
    var tmp = List.of(songs.value);
    if (tmp.contains(song)) {
      print('Removing song from album');
      tmp.remove(song);
      await widget.db.delAlbumSong(itemToEdit!.getEntry(),
          (await widget.db.getSongData(int.parse(song.id)))!);
      songs.value = tmp;
    }
  }

  //views
  @override
  Widget createView(BuildContext context) {
    return Center(
      child: Column(
        children: [
          albumForm,
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await create();
                    await setRead();
                  },
                  child: Text('Save'),
                  // style: ButtonStyle(
                  //   backgroundColor: Theme.of(context).,
                  // ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                ElevatedButton(
                  onPressed: () async {
                    await cancel();
                  },
                  child: Text('cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget readView(BuildContext context) {
    return ValueListenableBuilder<List<AlbumData>>(
      valueListenable: widget.app.albumsNotifier,
      builder: ((context, newalbums, _) {
        print('got albums: ${newalbums.toList()}');
        return RefreshIndicator(
          onRefresh: () async {
            await widget.app.loadAlbums();
            setState(() {});
          },
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  //physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: newalbums.length,
                  itemBuilder: (context, index) {
                    switch (index) {
                      default:
                        AlbumData album = newalbums[index];

                        var albumContextBtn = getAlbumContext(context, album);
                        return ListTile(
                          enabled: true,
                          onTap: () async {
                            //print('tap');
                            await setUpdate(album);
                          },
                          onLongPress: () {
                            //print('long press');
                            //print(widget.songContexts[song]);
                            albumContexts[album]!.showDialog();
                          },
                          leading: ArtUri(Uri.parse(album.art)),
                          title: Text(album.title),
                          subtitle: Text(album.description),
                          trailing: albumContextBtn,
                        );
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('Create album...'),
                trailing: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () async {
                  await setCreate();
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget updateView(BuildContext context) {
    if (itemToEdit == null) {
      return Text('Invalid album');
    }
    var album = itemToEdit!;
    print('${songs.value.length} songs gotten');
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ExpansionTile(
                    title: Text(album.title),
                    onExpansionChanged: (isExpanded) {
                      setState(() {
                        print('isExpanded: $formExpanded');
                        formExpanded = !isExpanded;
                      });
                    },
                    children: [
                      albumForm,
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () async {
                            await update(album);
                            await setRead();
                          },
                          child: Text('Save'),
                          // style: ButtonStyle(
                          //   backgroundColor: Theme.of(context).,
                          // ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('Add songs...'),
                    trailing: Icon(
                      Icons.add_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    onTap: () async {
                      //avoid dialog being closed after choosing option
                      List<MediaItem> selected = [];
                      await Future.delayed(Duration(seconds: 0), () async {
                        await SelectDialog.showModal<MediaItem>(context,
                            label: 'Select songs to add.',
                            multipleSelectedValues: selected,
                            items: widget.app.songsNotifier.value
                                .map(AudioInterface.getTag)
                                .toList(),
                            itemBuilder: (context, tag, isSelected) {
                          return ListTile(
                            title: Text(tag.title),
                            subtitle: Text(tag.artist ?? ''),
                            trailing:
                                (isSelected ? Icon(Icons.check_rounded) : null),
                          );
                        }, onMultipleItemsChange:
                                (List<MediaItem> selectedSong) {
                          setState(() {
                            selected = selectedSong;
                          });
                        });
                      }).then((value) async {
                        print('selected: ${selected.length}');
                        List<MediaItem> tmp = List.from(songs.value);
                        for (var song in selected) {
                          await widget.db.addAlbumSong(
                            album.getEntry(),
                            (await widget.db.getSongData(int.parse(song.id)))!,
                          );
                          tmp.add(song);
                        }
                        songs.value = tmp;
                      });
                    },
                  ),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {},
                    itemCount: songs.value.length,
                    itemBuilder: (context, index) {
                      MediaItem song = songs.value[index];
                      //int songId = int.tryParse(song.id) ?? -1;
                      //SongData songData;

                      return ListTile(
                        key: Key(index.toString()),
                        leading: ArtUri(song.artUri ?? Uri.parse('')),
                        title: Text(song.title),
                        subtitle: Text(song.artist ?? ''),
                        trailing: getSongContext(context, album, song),
                      );
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await cancel();
              },
              child: Text('Back'),
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
