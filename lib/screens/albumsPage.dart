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

  Future<void> setAlbumSongs() async {
    if (itemToEdit == null) return;
    List<MediaItem> tmp = [];
    List<SongDataDB> songsDB = await widget.db.getAlbumSongs(itemToEdit!);

    for (var song in songsDB) {
      tmp.add(AudioInterface.getTag(SongData.fromDB(song).source));
    }
    songs.value = tmp;
  }

  ContextPopupButton getalbumContext(BuildContext context, AlbumData album) {
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
                    Expanded(
                      child: Text(
                        'Create a album',
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  newName.text = '';
                  newArtist.text = '';
                  newDescription.text = '';
                  newArt.text = '';
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Name'),
                        subtitle: TextFormField(
                          controller: newName,
                        ),
                      ),
                      ListTile(
                        title: const Text('Artist'),
                        subtitle: TextFormField(
                          controller: newArtist,
                        ),
                      ),
                      ListTile(
                        title: const Text('Description'),
                        subtitle: TextFormField(
                          controller: newDescription,
                        ),
                      ),
                      ListTile(
                        title: const Text('Album Art'),
                        subtitle: TextFormField(
                          controller: newArt,
                          onChanged: (text) async {
                            artUriNotifier.value = text;
                          },
                          onFieldSubmitted: (text) async {
                            artUriNotifier.value = text;
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
            ),
            Row(
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
                Container(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await cancel();
                  },
                  child: Text('cancel'),
                ),
              ],
            ),
          ],
        ),
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
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: newalbums.length,
                    itemBuilder: (context, index) {
                      switch (index) {
                        default:
                          AlbumData album = newalbums[index];

                          var albumContextBtn = getalbumContext(context, album);
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
    //setalbumSongs();
    print('${songs.value.length} songs gotten');
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            ExpandablePanel(
              theme: ExpandableThemeData(
                hasIcon: true,
                iconColor: Theme.of(context).primaryColor,
              ),
              header: Center(
                child: Text(
                  album.title,
                  style: TextStyle(fontSize: 25),
                ),
              ),
              collapsed: Center(
                child: Text(
                  album.description,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
              expanded: Column(
                children: [
                  ListTile(
                    title: const Text('Title:'),
                    subtitle: TextFormField(
                      controller: newName,
                    ),
                  ),
                  ListTile(
                    title: const Text('Artist'),
                    subtitle: TextFormField(
                      controller: newArtist,
                    ),
                  ),
                  ListTile(
                    title: const Text('Description'),
                    subtitle: TextFormField(
                      controller: newDescription,
                    ),
                  ),
                  ListTile(
                    title: const Text('Album Art'),
                    subtitle: TextFormField(
                      controller: newArt,
                      onChanged: (text) async {
                        artUriNotifier.value = text;
                      },
                      onFieldSubmitted: (text) async {
                        artUriNotifier.value = text;
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
                  ElevatedButton(
                    onPressed: () async {
                      await update(album);
                      await setRead();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await setAlbumSongs();
                        setState(() {});
                      },
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: ValueListenableBuilder<List<MediaItem>>(
                          valueListenable: songs,
                          builder: (context, value, _) {
                            return ReorderableListView.builder(
                              onReorder: (int oldIndex, int newIndex) async {
                                //await AudioInterface.moveGeneric(list, oldIndex, newIndex)
                              },
                              itemCount: songs.value.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return ListTile(
                                    title: Text('Add songs...'),
                                    trailing: Icon(
                                      Icons.add_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onTap: () async {
                                      //avoid dialog being closed after choosing option
                                      List<MediaItem> selected = [];
                                      await Future.delayed(Duration(seconds: 0),
                                          () async {
                                        await SelectDialog.showModal<MediaItem>(
                                            context,
                                            label: 'Select songs to add.',
                                            multipleSelectedValues: selected,
                                            items:
                                                widget.app.songsNotifier.value
                                                    .map(AudioInterface.getTag)
                                                    .toList(), itemBuilder:
                                                (context, tag, isSelected) {
                                          return ListTile(
                                            title: Text(tag.title),
                                            subtitle: Text(tag.artist ?? ''),
                                            trailing: (isSelected
                                                ? Icon(Icons.check_rounded)
                                                : null),
                                          );
                                        }, onMultipleItemsChange:
                                                (List<MediaItem> selectedSong) {
                                          setState(() {
                                            selected = selectedSong;
                                          });
                                        });
                                      }).then((value) async {
                                        print('selected: ${selected.length}');
                                        List<MediaItem> tmp =
                                            List.from(songs.value);
                                        for (var song in selected) {
                                          await widget.db.addAlbumSong(
                                            album.getEntry(),
                                            (await widget.db.getSongData(
                                                int.parse(song.id)))!,
                                          );
                                          tmp.add(song);
                                        }
                                        songs.value = tmp;
                                      });
                                    },
                                  );
                                } else {
                                  newName.text = album.title;
                                  newArtist.text = album.artist;
                                  newDescription.text = album.description;
                                  newArt.text = album.art;
                                  var tag = songs.value[index - 1];
                                  return ListTile(
                                    leading:
                                        ArtUri(tag.artUri ?? Uri.parse('')),
                                    title: Text(tag.title),
                                    subtitle: Text(tag.artist ?? ''),
                                    trailing: ContextPopupButton(
                                      icon: Icon(Icons.more_vert),
                                      itemBuilder: (context) {
                                        Map<String, ContextItemTuple> choices =
                                            {
                                          'Remove': ContextItemTuple(
                                              Icons.remove_circle_rounded,
                                              () async {
                                            await deleteSong(tag);
                                          }),
                                        };
                                        List<PopupMenuItem<String>> items = [];
                                        for (var val in choices.keys) {
                                          var choice = choices[val];
                                          items.add(
                                            PopupMenuItem(
                                              onTap: choice!.onPress,
                                              child: Row(
                                                children: [
                                                  Icon(choice.icon,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  Expanded(
                                                    child: Text(
                                                      val,
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                        return items;
                                      },
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      child: Text('Back'),
                      onPressed: () async {
                        await cancel();
                      },
                    ),
                  )
                ],
              ),
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
