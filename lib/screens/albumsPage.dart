import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:woodbirdmp3/database/database.dart';
import 'package:woodbirdmp3/models/AudioInterface.dart';
import 'package:woodbirdmp3/models/states/album/albumData.dart';
import 'package:woodbirdmp3/models/states/song/SongData.dart';
import 'package:woodbirdmp3/screens/CRUDPage.dart';
import 'package:woodbirdmp3/screens/themedPage.dart';
import 'package:woodbirdmp3/widgets/contextPopupButton.dart';
import 'package:path/path.dart' as p;

import '../models/contextItemTuple.dart';
import '../platform_specific/device.dart';
import '../widgets/artUri.dart';

class AlbumsPage extends ThemedPage {
  AlbumsPage({super.key, required super.title});

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
  State<StatefulWidget> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends CRUDState<AlbumData> {
  ValueNotifier<List<MediaItem>> songs = ValueNotifier(<MediaItem>[]);
  ValueNotifier<String> artUriNotifier = ValueNotifier<String>('');
  //ValueNotifier<String> albumTitle = ValueNotifier<String>('');

  TextEditingController newName = TextEditingController(text: '');
  TextEditingController newArtist = TextEditingController(text: '');
  TextEditingController newDescription = TextEditingController(text: '');
  TextEditingController newArt = TextEditingController(text: '');

  List<AlbumData> get albums => widget.app.albumsNotifier.value;
  set albums(value) => widget.app.albumsNotifier.value = value;

  ScrollController scrollController = ScrollController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget get albumForm => Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text('Edit Album'),
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
                  labelText: 'Artist',
                ),
                controller: newArtist,
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
                          var createdAlbums = await create();
                          await setUpdate(createdAlbums[0]);
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
              //       //update Album title
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
    List<SongDataDB> songsDB = await widget.db.getAlbumSongs(itemToEdit!.getEntry());
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
          'Edit Album': ContextItemTuple(
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
                        child: albumForm,
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

  ContextPopupButton getAlbumContext(BuildContext context, AlbumData Album) {
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
              List<AudioSource> songs =
                  (await widget.db.getAlbumSongs(Album.getEntry())).map((s) => SongData.fromDB(s).source).toList();
              await widget.app.audioInterface.setQueue(songs);
            },
          ),
          'Add to queue': ContextItemTuple(
            Icons.playlist_add_rounded,
            () async {
              List<AudioSource> songs =
                  (await widget.db.getAlbumSongs(Album.getEntry())).map((s) => SongData.fromDB(s).source).toList();
              await widget.app.audioInterface.addToQueue(songs);
            },
          ),
          'Edit': ContextItemTuple(Icons.edit_rounded, () async {
            await setUpdate(Album);
          }),
          'Delete': ContextItemTuple(Icons.delete_rounded, () async {
            await delete(Album);
          }),
        };
        return widget.buildPopupItems(context, choices);
      },
    );

    //AlbumContexts[Album] = popup;
    //return popup;
  }

  ContextPopupButton getSongContext(BuildContext context, AlbumData Album, MediaItem song, int songIndex) {
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

    //AlbumContexts[Album] = popup;
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
  Future<void> setUpdate(AlbumData item, [_]) async {
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
    //albumTitle.value = itemToEdit!.title;
    newDescription.text = itemToEdit!.description;
    newArt.text = itemToEdit!.art;
    artUriNotifier.value = newArt.text;
    await setAlbumSongs();

    state = ViewState.update;
  }

  //crud ops
  @override
  Future<List<AlbumData>> create() async {
    var data = AlbumData(
        title: newName.text, songOrder: [], artist: newArtist.text, description: newDescription.text, art: newArt.text);
    await update(data);
    return [data];
  }

  @override
  Future<AlbumData> update(AlbumData item) async {
    print('Album id before: ${item.id}');
    item.title = newName.text;
    //set appbar title
    widget.app.navigation.setAppBarTitle(item.title);
    item.artist = newArtist.text;
    item.description = newDescription.text;
    item.art = newArt.text;
    //var tmp = List.of(Albums);
    print('saving Album changes to db');
    //bool isNew = (item.id == null || !await widget.db.AlbumExists(item.id!));
    await item.saveData();
    //albumTitle.value = newName.text;
    await widget.app.loadAlbums();
    return item;
  }

  @override
  Future<void> delete(AlbumData item) async {
    //var tmp = <AlbumData>[];
    if (albums.contains(item)) {
      await widget.db.delAlbumData(item.getEntry());
      await widget.app.loadAlbums();
    } else {
      print('Album not in list, delete failed');
    }
  }

  Future<void> deleteSong(MediaItem song, int songIndex) async {
    int songID = int.parse(song.id);
    var tmp = List.of(songs.value);
    if (tmp.contains(song) && songID > -1) {
      int itemsDeleted = await widget.db.delAlbumSong(itemToEdit!.getEntry(), (await widget.db.getSongData(songID))!);
      if (itemsDeleted > 0) {
        //   print('Removing song from Album');
        //   tmp.remove(song);
        //   //update Album
        //   itemToEdit = AlbumData.fromDB(
        //       (await widget.db.getAlbumData(itemToEdit!.id!))!);
        //   //update songs
        //   songs.value = tmp;
        //   //return true;
        //   setState(() {});
        //remove item from order by index
        var Album = itemToEdit!;
        print('removing songOrder at $songIndex');
        print('SongOrder before Delete: ${Album.songOrder}');
        Album.songOrder.removeAt(songIndex);
        print('SongOrder after Delete: ${Album.songOrder}');
        //remove song from songs by index
        tmp.removeAt(songIndex);
        //update Album in DB
        await updateAlbum(Album);
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
    var Album = itemToEdit!;
    Album.songOrder = songOrder;
    print('After reorder: ${songOrder.toString()}');
    //update Album in DB
    await updateAlbum(Album);
    //save songs
    songs.value = songList;
    setState(() {});
  }

  Future<AlbumData> updateAlbum(AlbumData Album) async {
    //update Album in DB
    await widget.db.updateAlbumData(Album.getEntry());
    //update itemToEdit
    itemToEdit = Album;
    //reload Albums
    await widget.app.loadAlbums();
    return Album;
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
                  albumForm,
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
    return ValueListenableBuilder<List<AlbumData>>(
      valueListenable: widget.app.albumsNotifier,
      builder: ((context, newAlbums, _) {
        print('got Albums: ${newAlbums.toList()}');
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Column(
            children: [
              ListTile(
                title: const Text('Create Album...'),
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
                  itemCount: newAlbums.length,
                  itemBuilder: (context, index) {
                    AlbumData album = newAlbums[index];

                    var albumContextBtn = getAlbumContext(context, album);
                    return ListTile(
                      enabled: true,
                      onTap: () async {
                        //print('tap');
                        await setUpdate(album);
                      },
                      onLongPress: albumContextBtn.showDialog,
                      leading: ArtUri(Uri.parse(album.art)),
                      title: Text(album.title),
                      subtitle: Text(album.artist),
                      trailing: albumContextBtn,
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
      return const Text('Invalid Album');
    }
    //var Album = itemToEdit!;
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
                  //create copy of Album
                  var Album = itemToEdit!;
                  //create copy of songs
                  List<MediaItem> tmp = List.from(songs.value);
                  for (var song in selected) {
                    await widget.db.addAlbumSong(
                      itemToEdit!.getEntry(),
                      (await widget.db.getSongData(int.parse(song.id)))!,
                    );
                    //add song
                    tmp.add(song);
                    //add song to song order
                    Album.songOrder.add(int.parse(song.id));
                  }
                  //update Album in DB
                  updateAlbum(Album);
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
