import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/models/states/playlist/playlistData.dart';
import 'package:test_project/models/states/song/songData.dart';
import 'package:test_project/screens/CRUDPage.dart';
import 'package:test_project/widgets/contextPopupButton.dart';

import '../models/contextItemTuple.dart';
import '../widgets/appBar.dart';

class PlaylistsPage extends CRUDPage<PlaylistData> {
  PlaylistsPage({super.key, required super.title}) {
    editingNotifier = ValueNotifier<PlaylistData?>(null);
  }

  late ValueNotifier<PlaylistData?> editingNotifier;

  List<SongData> songs = [];

  PlaylistData? get playlistToEdit => editingNotifier.value;

  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newDescription = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

  Map<PlaylistData, ContextPopupButton> playlistContexts =
      <PlaylistData, ContextPopupButton>{};

  List<PlaylistData> get playlists => app.playlistsNotifier.value;
  set playlists(playlists) => app.playlistsNotifier.value = playlists;

  Future<void> setPlaylistSongs() async {
    if (state != ViewState.update) return;

    songs.clear();
    List<SongDataDB> songsDB = await db.getPlaylistSongs(playlistToEdit!);

    for (var song in songsDB) {
      songs.add(SongData.fromDB(song));
    }
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
          'Set queue': ContextItemTuple(Icons.queue_music_rounded, () async {}),
          'Add to queue':
              ContextItemTuple(Icons.playlist_add_rounded, () async {}),
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

  @override
  AppBarData getDefaultAppBar() {
    return AppBarData(
      title,
      <Widget>[
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            Map<String, ContextItemTuple> choices = {
              'Create Playlist': ContextItemTuple(
                Icons.queue_rounded,
                () async {
                  await setCreate();
                },
              ),
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
        )
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _PlaylistsPageState();

  //set states
  @override
  Future<void> setCreate() async {
    print('switching to create');
    state = ViewState.create;
  }

  @override
  Future<void> setRead() async {
    print('switching to read');
    state = ViewState.read;
  }

  @override
  Future<void> setUpdate(PlaylistData item) async {
    print('switching to update');
    if (item.id != null) {
      print('editing ${item.name} - ${item.id}');
    }
    editingNotifier.value = item;
    state = ViewState.update;
  }

  @override
  Future<void> setDelete(PlaylistData item) async {
    print('switching to delete');
    editingNotifier.value = item;
    state = ViewState.delete;
  }

  @override
  Future<void> cancel() async {
    print('cancelling');
    editingNotifier.value = null;
    state = ViewState.read;
  }

  //crud ops
  @override
  Future<PlaylistData> create() async {
    var data = PlaylistData(name: '');
    await update(data);
    return data;
  }

  @override
  Future<void> update(PlaylistData item) async {
    item.name = newName.text;
    item.description = newDescription.text;
    item.art = newArt.text;
    var tmp = List.of(playlists);
    var exists = false;
    print('saving playlist changes to db');
    exists = (item.id != null && await db.playlistExists(item.id!));
    await item.saveData();
    if (!exists) tmp.add(item);
    playlists = tmp;
  }

  @override
  Future<void> delete(PlaylistData item) async {
    var tmp = List.of(playlists);
    if (playlists.contains(item)) {
      await db.delPlaylistData(item.getEntry());
      tmp.remove(item);
      playlists = tmp;
    } else {
      print('playlist not in list, delete failed');
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
                  child: ListView.builder(
                      itemCount: 3 + songs.length,
                      itemBuilder: (context, index) {
                        newName.text = '';
                        newDescription.text = '';
                        newArt.text = '';
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
                                child: const Text('Description:'),
                              ),
                              title: TextFormField(
                                controller: newDescription,
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
                          default:
                            return ListTile(
                              title: Text(songs[index].name),
                              subtitle: Text(songs[index].artist),
                            );
                        }
                      }),
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
      valueListenable: app.playlistsNotifier,
      builder: ((context, newPlaylists, _) {
        print('got playlists: ${newPlaylists.toList()}');
        return RefreshIndicator(
            onRefresh: () async => () {},
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
                  itemCount: newPlaylists.length,
                  itemBuilder: (context, index) {
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
                      title: Text(playlist.name),
                      subtitle: Text(playlist.description),
                      trailing: playlistContextBtn,
                    );
                  },
                )));
      }),
    );
  }

  @override
  Widget updateView(BuildContext context) {
    if (playlistToEdit == null) {
      return Text('Invalid Playlist');
    }
    var playlist = playlistToEdit!;
    () async {
      await setPlaylistSongs();
    }();
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
                        playlist.name,
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
                  newName.text = playlist.name;
                  newDescription.text = playlist.description;
                  newArt.text = playlist.art;
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: ListView.builder(
                      itemCount: 3 + songs.length,
                      itemBuilder: (context, index) {
                        newName.text = playlist.name;
                        newDescription.text = playlist.description;
                        newArt.text = playlist.art;
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
                                child: const Text('Description:'),
                              ),
                              title: TextFormField(
                                controller: newDescription,
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
                          default:
                            return ListTile(
                              title: Text(songs[index].name),
                              subtitle: Text(songs[index].artist),
                            );
                        }
                      }),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await update(playlist);
                  },
                  child: Text('Save'),
                ),
                Container(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
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
    return readView(context);
  }
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ViewState>(
      valueListenable: widget.stateNotifier,
      builder: (context, state, _) {
        print('current state: $state');
        switch (state) {
          case ViewState.create:
            return widget.createView(context);
          case ViewState.read:
            return widget.readView(context);
          case ViewState.update:
            return widget.updateView(context);
          case ViewState.delete:
            return widget.deleteView(context);
          default:
            return Center(child: Text('Invalid State'));
        }
      },
    );
  }
}
