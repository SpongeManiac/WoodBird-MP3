import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:test_project/database/database.dart';
import 'package:test_project/models/states/playlist/playlistData.dart';
import 'package:test_project/models/states/song/songData.dart';
import 'package:test_project/screens/CRUDPage.dart';
import 'package:test_project/screens/songsPage.dart';
import 'package:test_project/screens/themedPage.dart';
import 'package:test_project/widgets/actionButtonLayout.dart';
import 'package:test_project/widgets/contextPopupButton.dart';

import '../models/contextItemTuple.dart';
import '../widgets/appBar.dart';

class PlaylistsPage extends CRUDPage {
  PlaylistsPage({super.key, required super.title}) {
    editingNotifier = ValueNotifier<PlaylistData?>(null);
  }

  late ValueNotifier<PlaylistData?> editingNotifier;

  List<SongData> songs = [];

  PlaylistData? get playlistToEdit => editingNotifier.value;

  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newDescription = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

  @override
  State<StatefulWidget> createState() => _PlaylistsPageState();

  @override
  Future<void> saveState() async {}

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
          'Edit': ContextItemTuple(Icons.edit_rounded, () async {}),
          'Delete': ContextItemTuple(Icons.delete_rounded, () async {}),
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

  Future<void> createPlaylist() async {
    print('switching to create');
    state = ViewState.create;
  }

  Future<void> editPlaylist(PlaylistData playlist) async {
    playlist.name = newName.text;
    playlist.description = newDescription.text;
    playlist.art = newArt.text;
    var tmp = List.of(playlists);
    print('saving playlist changes to db');
    await playlist.saveData();
    tmp.add(playlist);
    playlists = tmp;
    editingNotifier.value = null;
    state = ViewState.read;
  }

  Future<void> delPlaylist(PlaylistData playlist) async {
    var tmp = List.of(playlists);
    if (playlists.contains(playlist)) {
      await db.delPlaylistData(playlist.getEntry());
      tmp.remove(playlist);
      playlists = tmp;
    } else {
      print('playlist not in list, delete failed');
    }
  }

  Future<void> playlistTapped(PlaylistData playlist) async {
    editingNotifier.value = playlist;
    state = ViewState.update;
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
              'Add Playlist': ContextItemTuple(
                Icons.folder,
                () async {
                  await createPlaylist();
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

  @override
  Widget create(BuildContext context) {
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
                  onPressed: () {
                    var playlist = PlaylistData(
                        name: newName.text,
                        description: newDescription.text,
                        art: newArt.text);
                    editPlaylist(playlist);
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

  @override
  Widget read(BuildContext context) {
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
                      onTap: () {
                        //print('tap');
                        playlistTapped(playlist);
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
  Widget update(BuildContext context) {
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
                  onPressed: () {
                    editPlaylist(playlist);
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
                    state = ViewState.read;
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
  Widget delete(BuildContext context) {
    // TODO: implement delete
    throw UnimplementedError();
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
            return widget.create(context);
          case ViewState.read:
            return widget.read(context);
          case ViewState.update:
            return widget.update(context);
          case ViewState.delete:
            return widget.delete(context);
          default:
            return Center(child: Text('Invalid State'));
        }
      },
    );
  }
}
