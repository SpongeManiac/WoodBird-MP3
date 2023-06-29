import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
import '../platform_specific/device.dart';
import '../widgets/artUri.dart';

class PlaylistsPage extends ThemedPage {
  PlaylistsPage({super.key, required super.title});

  @override
  void initState(BuildContext context) {
    // TODO: implement initState
    super.initState(context);
    setAndroidBack(
      context,
      () async {
        app.navigation.goto(context, '/');
        return false;
      },
      Icons.home_rounded,
    );
  }

  @override
  State<StatefulWidget> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends CRUDState<PlaylistData> {
  ValueNotifier<List<MediaItem>> songs = ValueNotifier(<MediaItem>[]);
  ValueNotifier<String> artUriNotifier = ValueNotifier<String>('');
  //ValueNotifier<String> playlistTitle = ValueNotifier<String>('');
  //ValueNotifier<String> playlistArt = ValueNotifier<String>('');

  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newDescription = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

  Map<PlaylistData, ContextPopupButton> playlistContexts = <PlaylistData, ContextPopupButton>{};

  List<PlaylistData> get playlists => widget.app.playlistsNotifier.value;
  set playlists(playlists) => widget.app.playlistsNotifier.value = playlists;

  ScrollController scrollController = ScrollController();

  bool formExpanded = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget get playlistForm => Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text('Edit Playlist'),
              ),
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
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                controller: newDescription,
                validator: (value) => validateDesc(value),
                minLines: 1,
                maxLength: 1024,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (state == ViewState.create) {
                        () async {
                          var createdPlaylists = await create();
                          await setUpdate(createdPlaylists[0]);
                        }();
                      }
                      if (state == ViewState.update) {
                        () async {
                          await update(itemToEdit!);
                        }();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                  ElevatedButton(
                    onPressed: () {
                      if (state == ViewState.create) {
                        () async {
                          await widget.app.navigation.androidOnBack();
                        }();
                      }
                      if (state == ViewState.update) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('cancel'),
                  ),
                ],
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     () async {
              //       await update(itemToEdit!);
              //       //update playlist title
              //     }();
              //     Navigator.of(context).pop();
              //   },
              //   child: const Text('Save'),
              // ),
              // IconButton(
              //   iconSize: 56,
              //   color: Theme.of(context).primaryColor,
              //   icon: ArtUri(
              //     Uri.parse(newArt.text),
              //     maxSize: 56,
              //   ),
              //   onPressed: () async {
              //     widget.app.loadingProgressNotifier.value = null;
              //     widget.app.loadingNotifier.value = true;
              //     var path = await (widget.app as DesktopApp).getArt();
              //     if (path.isNotEmpty) {
              //       setState(() {
              //         newArt.text = path;
              //       });
              //     }
              //     widget.app.loadingNotifier.value = false;
              //     widget.app.loadingProgressNotifier.value = null;
              //   },
              // ),
            ],
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    widget.initState(context);
    //create crud views
    //createView = createViewBuilder(context);
    //readView = readViewBuilder(context);
    //updateView = updateViewBuilder(context);
    //deleteView = deleteViewBuilder(context);
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

  Future<void> setPlaylistSongs() async {
    if (itemToEdit == null) return;
    List<MediaItem> tmp = [];
    List<SongDataDB> songsDB = await widget.db.getPlaylistSongs(itemToEdit!.getEntry());
    //sort songs
    for (var song in songsDB) {
      tmp.add(AudioInterface.getTag(SongData.fromDB(song).source));
    }

    songs.value = tmp;
  }

  ContextPopupButton getMoreContext(BuildContext context) {
    return ContextPopupButton(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
          'Edit Playlist': ContextItemTuple(
            Icons.edit_rounded,
            () async {
              //pop context to show dialog
              //Navigator.of(context).pop();
              //show dialog
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: SingleChildScrollView(
                        child: playlistForm,
                      ),
                    );
                  },
                );
              });
            },
          ),
        };
        return widget.buildPopupItems(context, choices);
      },
    );
  }

  ContextPopupButton getPlaylistContext(BuildContext context, PlaylistData playlist) {
    return ContextPopupButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).primaryColor,
      ),
      itemBuilder: (context) {
        Map<String, ContextItemTuple> choices = <String, ContextItemTuple>{
          'Set queue': ContextItemTuple(
            Icons.queue_music_rounded,
            () async {
              List<AudioSource> songs = (await widget.db.getPlaylistSongs(playlist.getEntry()))
                  .map((s) => SongData.fromDB(s).source)
                  .toList();
              await widget.app.audioInterface.setQueue(songs);
            },
          ),
          'Add to queue': ContextItemTuple(
            Icons.playlist_add_rounded,
            () async {
              List<AudioSource> songs = (await widget.db.getPlaylistSongs(playlist.getEntry()))
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
        return widget.buildPopupItems(context, choices);
      },
    );

    //playlistContexts[playlist] = popup;
    //return popup;
  }

  ContextPopupButton getSongContext(BuildContext context, PlaylistData playlist, MediaItem song, int songIndex) {
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
              await deleteSong(song, songIndex);
            },
          ),
        };
        return widget.buildPopupItems(context, choices);
      },
    );

    //playlistContexts[playlist] = popup;
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
  Future<void> setCreate([onBackOverride]) async {
    await super.setCreate(onBackOverride);
    newName.text = '';
    newDescription.text = '';
    newArt.text = '';
    artUriNotifier.value = '';
  }

  @override
  Future<void> setRead([onBackOverride]) async {
    super.setRead(onBackOverride);
    artUriNotifier.value = '';
  }

  @override
  Future<void> setUpdate(PlaylistData item, [_]) async {
    //print('switching to update');
    if (item.id != null) {
      print('editing ${item.title} - ${item.id}');
    }
    widget.app.navigation.setAppBarTitle(item.title);
    await super.setUpdate(
      item,
      //override onBack to change appBarTitle back to normal
      () async {
        widget.app.navigation.setAppBarTitle(widget.title);
        widget.app.navigation.delAppBarAction('more');
        await cancel();
        return false;
      },
    );
    widget.app.navigation.addAppBarAction('more', getMoreContext(context));
    newName.text = itemToEdit!.title;
    newDescription.text = itemToEdit!.description;
    newArt.text = artUriNotifier.value = itemToEdit!.art;
    await setPlaylistSongs();

    state = ViewState.update;
  }

  //crud ops
  @override
  Future<List<PlaylistData>> create() async {
    var data = PlaylistData(title: newName.text, songOrder: [], description: newDescription.text, art: newArt.text);
    await update(data);
    return [data];
  }

  @override
  Future<PlaylistData> update(PlaylistData item) async {
    print('playlist id before: ${item.id}');
    item.title = newName.text;
    //update appbar title
    widget.app.navigation.setAppBarTitle(item.title);
    item.description = newDescription.text;
    item.art = artUriNotifier.value = newArt.text;
    //var tmp = List.of(playlists);
    print('saving playlist changes to db');
    //bool isNew = (item.id == null || !await widget.db.playlistExists(item.id!));
    await item.saveData();
    await widget.app.loadPlaylists();
    return item;
  }

  @override
  Future<void> delete(PlaylistData item) async {
    //var tmp = List.of(playlists);
    if (playlists.contains(item)) {
      await widget.db.delPlaylistData(item.getEntry());
      await widget.app.loadPlaylists();
    } else {
      print('playlist not in list, delete failed');
    }
  }

  Future<void> deleteSong(MediaItem song, int songIndex) async {
    int songID = int.parse(song.id);
    var tmp = List.of(songs.value);
    if (tmp.contains(song) && songID > -1) {
      int itemsDeleted =
          await widget.db.delPlaylistSong(itemToEdit!.getEntry(), (await widget.db.getSongData(songID))!);
      if (itemsDeleted > 0) {
        //   print('Removing song from playlist');
        //   tmp.remove(song);
        //   //update playlist
        //   itemToEdit = PlaylistData.fromDB(
        //       (await widget.db.getPlaylistData(itemToEdit!.id!))!);
        //   //update songs
        //   songs.value = tmp;
        //   //return true;
        //   setState(() {});
        //remove item from order by index
        var playlist = itemToEdit!;
        print('removing songOrder at $songIndex');
        print('SongOrder before Delete: ${playlist.songOrder}');
        playlist.songOrder.removeAt(songIndex);
        print('SongOrder after Delete: ${playlist.songOrder}');
        //remove song from songs by index
        tmp.removeAt(songIndex);
        //update playlist in DB
        await updatePlaylist(playlist);
        //save songs
        songs.value = tmp;
        setState(() {});
      }
    }
    //return false;
  }

  Future<void> reorderSong(int oldIndex, int newIndex) async {
    var songList = songs.value;
    print('Before reorder: ${songList.map((s) => int.parse(s.id)).toList().toString()}');
    songList = AudioInterface.moveGeneric(songList, oldIndex, newIndex);
    var songOrder = songList.map((s) => int.parse(s.id)).toList();
    var playlist = itemToEdit!;
    playlist.songOrder = songOrder;
    print('After reorder: ${songOrder.toString()}');
    //update playlist in DB
    await updatePlaylist(playlist);
    //save songs
    songs.value = songList;
    setState(() {});
  }

  Future<PlaylistData> updatePlaylist(PlaylistData playlist) async {
    //update playlist in DB
    await widget.db.updatePlaylistData(playlist.getEntry());
    //update itemToEdit
    itemToEdit = playlist;
    //reload playlists
    await widget.app.loadPlaylists();
    return playlist;
  }

  //views
  @override
  Widget createViewBuilder(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                children: [
                  playlistForm,
                  //Text('${(song as UriAudioSource).uri}'),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       ElevatedButton(
          //         onPressed: () async {
          //           await create();
          //           await setRead();
          //         },
          //         child: Text('Save'),
          //         // style: ButtonStyle(
          //         //   backgroundColor: Theme.of(context).,
          //         // ),
          //       ),
          //       Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
          //       ElevatedButton(
          //         onPressed: () async {
          //           await cancel();
          //         },
          //         child: Text('cancel'),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget readViewBuilder(BuildContext context) {
    return ValueListenableBuilder<List<PlaylistData>>(
      valueListenable: widget.app.playlistsNotifier,
      builder: ((context, newPlaylists, _) {
        print('got playlists: ${newPlaylists.toList()}');
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Column(
            children: [
              ListTile(
                title: const Text('Create Playlist...'),
                trailing: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () async {
                  await setCreate();
                },
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  //physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: newPlaylists.length,
                  itemBuilder: (context, index) {
                    PlaylistData playlist = newPlaylists[index];

                    var playlistContextBtn = getPlaylistContext(context, playlist);
                    return ListTile(
                      enabled: true,
                      onTap: () async {
                        //print('tap');
                        await setUpdate(playlist);
                      },
                      onLongPress: playlistContextBtn.showDialog,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ArtUri(
                          Uri.parse(playlist.art),
                        ),
                      ),
                      title: Text(playlist.title),
                      subtitle: Text(playlist.description),
                      trailing: playlistContextBtn,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget updateViewBuilder(BuildContext context) {
    if (itemToEdit == null) {
      return const Text('Invalid playlist');
    }
    //var playlist = itemToEdit!;
    print('${songs.value.length} songs gotten');
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Opacity(
                  opacity: 0.10,
                  child: ArtUri(
                    Uri.parse(itemToEdit!.art),
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ListTile(
              title: const Text('Add songs...'),
              trailing: Icon(
                Icons.add_rounded,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () async {
                //avoid dialog being closed after choosing option
                List<MediaItem> selected = [];
                await Future.delayed(const Duration(seconds: 0), () async {
                  await SelectDialog.showModal<MediaItem>(context,
                      label: 'Select songs to add.',
                      multipleSelectedValues: selected,
                      items: widget.app.songsNotifier.value.map(AudioInterface.getTag).toList(),
                      itemBuilder: (context, tag, isSelected) {
                    return ListTile(
                      title: Text(tag.title),
                      subtitle: Text(tag.artist ?? ''),
                      trailing: (isSelected ? const Icon(Icons.check_rounded) : null),
                    );
                  }, onMultipleItemsChange: (List<MediaItem> selectedSong) {
                    setState(() {
                      selected = selectedSong;
                    });
                  });
                }).then((value) async {
                  //add selected songs to paylist
                  print('selected: ${selected.length}');
                  //create copy of playlist
                  var playlist = itemToEdit!;
                  //create copy of songs
                  List<MediaItem> tmp = List.from(songs.value);
                  for (var song in selected) {
                    await widget.db.addPlaylistSong(
                      itemToEdit!.getEntry(),
                      (await widget.db.getSongData(int.parse(song.id)))!,
                    );
                    //add song
                    tmp.add(song);
                    //add song to song order
                    playlist.songOrder.add(int.parse(song.id));
                  }
                  //update playlist in DB
                  updatePlaylist(playlist);
                  //save songs
                  songs.value = tmp;
                  setState(() {});
                });
              },
            ),
            Expanded(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                scrollController: scrollController,
                //buildDefaultDragHandles: false,
                padding: const EdgeInsets.all(10),
                onReorder: reorderSong,
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
                    trailing: getSongContext(context, itemToEdit!, song, index),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget deleteViewBuilder(BuildContext context) {
    setRead();
    return readViewBuilder(context);
  }
}
