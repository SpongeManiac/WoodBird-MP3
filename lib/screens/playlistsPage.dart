import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:marquee/marquee.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/models/AudioInterface.dart';
import 'package:test_project/models/states/playlist/playlistData.dart';
import 'package:test_project/models/states/song/songData.dart';
import 'package:test_project/screens/CRUDPage.dart';
import 'package:test_project/screens/themedPage.dart';
import 'package:test_project/widgets/contextPopupButton.dart';
import 'package:path/path.dart' as p;

import '../models/contextItemTuple.dart';
import '../widgets/appBar.dart';
import '../widgets/artUri.dart';

class PlaylistsPage extends ThemedPage {
  PlaylistsPage({super.key, required super.title});

  @override
  AppBarData getDefaultAppBar() {
    return AppBarData(
      title,
    );
  }

  @override
  State<StatefulWidget> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends CRUDState<PlaylistData> {
  ValueNotifier<List<MediaItem>> songs = ValueNotifier(<MediaItem>[]);
  ValueNotifier<String> artUriNotifier = ValueNotifier<String>('');

  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newDescription = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

  Map<PlaylistData, ContextPopupButton> playlistContexts =
      <PlaylistData, ContextPopupButton>{};

  List<PlaylistData> get playlists => widget.app.playlistsNotifier.value;
  set playlists(playlists) => widget.app.playlistsNotifier.value = playlists;

  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  Future<void> setPlaylistSongs() async {
    if (itemToEdit == null) return;
    List<MediaItem> tmp = [];
    List<SongDataDB> songsDB = await widget.db.getPlaylistSongs(itemToEdit!);

    for (var song in songsDB) {
      tmp.add(AudioInterface.getTag(SongData.fromDB(song).source));
    }
    songs.value = tmp;
  }

  ContextPopupButton getPlaylistContext(
      BuildContext context, PlaylistData playlist) {
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
              List<AudioSource> songs =
                  (await widget.db.getPlaylistSongs(playlist))
                      .map((s) => SongData.fromDB(s).source)
                      .toList();
              await widget.app.audioInterface.setQueue(songs);
            },
          ),
          'Add to queue': ContextItemTuple(
            Icons.playlist_add_rounded,
            () async {
              List<AudioSource> songs =
                  (await widget.db.getPlaylistSongs(playlist))
                      .map((s) => SongData.fromDB(s).source)
                      .toList();
              await widget.app.audioInterface.addToQueue(songs);
            },
          ),
          'Edit': ContextItemTuple(Icons.edit_rounded, () async {
            await setUpdate(playlist);
          }),
          'Delete': ContextItemTuple(Icons.delete_rounded, () async {
            await delete(playlist);
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

    playlistContexts[playlist] = popup;
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
  Future<void> setUpdate(PlaylistData item) async {
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
    newDescription.text = itemToEdit!.description;
    newArt.text = itemToEdit!.art;
    artUriNotifier.value = newArt.text;
    await setPlaylistSongs();
    state = ViewState.update;
  }

  @override
  Future<void> setDelete(PlaylistData item) async {
    print('switching to delete');
    state = ViewState.delete;
  }

  //crud ops
  @override
  Future<List<PlaylistData?>> create() async {
    var data = PlaylistData(title: '');
    await update(data);
    return [data];
  }

  @override
  Future<PlaylistData> update(PlaylistData item) async {
    item.title = newName.text;
    item.description = newDescription.text;
    item.art = newArt.text;
    var tmp = List.of(playlists);
    print('saving playlist changes to db');
    bool isNew = (item.id == null || !await widget.db.playlistExists(item.id!));
    await item.saveData();
    if (isNew) {
      tmp.add(item);
    } else {
      tmp[tmp.indexOf(item)] = item;
    }
    playlists = tmp;
    return item;
  }

  @override
  Future<void> delete(PlaylistData item) async {
    var tmp = List.of(playlists);
    if (playlists.contains(item)) {
      await widget.db.delPlaylistData(item.getEntry());
      tmp.remove(item);
      playlists = tmp;
    } else {
      print('playlist not in list, delete failed');
    }
  }

  Future<void> deleteSong(MediaItem song) async {
    var tmp = List.of(songs.value);
    if (tmp.contains(song)) {
      print('Removing song from playlist');
      tmp.remove(song);
      await widget.db.delPlaylistSong(itemToEdit!.getEntry(),
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
                        'Create a playlist',
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
                        title: const Text('Name:'),
                        subtitle: TextFormField(
                          controller: newName,
                        ),
                      ),
                      ListTile(
                        title: const Text('Description:'),
                        subtitle: TextFormField(
                          controller: newDescription,
                        ),
                      ),
                      ListTile(
                        title: const Text('Playlist Art'),
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
    return ValueListenableBuilder<List<PlaylistData>>(
      valueListenable: widget.app.playlistsNotifier,
      builder: ((context, newPlaylists, _) {
        print('got playlists: ${newPlaylists.toList()}');
        return RefreshIndicator(
          onRefresh: () async {},
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
                    itemCount: newPlaylists.length,
                    itemBuilder: (context, index) {
                      switch (index) {
                        default:
                          PlaylistData playlist = newPlaylists[index];

                          var playlistContextBtn =
                              getPlaylistContext(context, playlist);
                          return ListTile(
                            enabled: true,
                            onTap: () async {
                              //print('tap');
                              await setUpdate(playlist);
                            },
                            onLongPress: () {
                              //print('long press');
                              //print(widget.songContexts[song]);
                              playlistContexts[playlist]!.showDialog();
                            },
                            leading: ArtUri(Uri.parse(playlist.art)),
                            title: Text(playlist.title),
                            subtitle: Text(playlist.description),
                            trailing: playlistContextBtn,
                          );
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text('Create Playlist...'),
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
      return Text('Invalid Playlist');
    }
    var playlist = itemToEdit!;
    //setPlaylistSongs();
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
                  playlist.title,
                  style: TextStyle(fontSize: 25),
                ),
              ),
              collapsed: Center(
                child: Text(
                  playlist.description,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
              expanded: Column(
                children: [
                  ListTile(
                    title: const Text('Name:'),
                    subtitle: TextFormField(
                      controller: newName,
                    ),
                  ),
                  ListTile(
                    title: const Text('Description'),
                    subtitle: TextFormField(
                      controller: newDescription,
                    ),
                  ),
                  ListTile(
                    title: const Text('Playlist Art'),
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
                      await update(playlist);
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
                        await setPlaylistSongs();
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
                            return ListView.builder(
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
                                            label:
                                                'Select playlists to add song to.',
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
                                          await widget.db.addPlaylistSong(
                                            playlist.getEntry(),
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
                                  newName.text = playlist.title;
                                  newDescription.text = playlist.description;
                                  newArt.text = playlist.art;
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
