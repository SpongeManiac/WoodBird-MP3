import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:woodbirdmp3/widgets/appBar.dart';

import '../database/database.dart';
import '../globals.dart' as globals;
import 'package:path/path.dart' as p;
import '../models/AudioInterface.dart';
import '../models/colorMaterializer.dart';
import '../models/states/album/albumData.dart';
import '../models/states/pages/homePageData.dart';
import '../models/states/playlist/playlistData.dart';
import '../screens/albumsPage.dart';
import '../screens/settingsPage.dart';
import '../screens/pageNav.dart';
import '../screens/playlistsPage.dart';
import '../screens/songsPage.dart';
import '../screens/themedPage.dart';
import '../widgets/flyout/flyout.dart';
import '../widgets/hideableFloatingAction.dart';

class BaseApp extends StatefulWidget {
  BaseApp({super.key, this.appTitle = 'WoodBird MP3', this.navTitle = 'WoodBird MP3'}) {
    () async {
      songsDir = await getSongsDir();
      artDir = await getArtDir();
    }();
  }

  late String songsDir;
  late String artDir;

  Future<String> getSongsDir() async {
    var docs = await getApplicationDocumentsDirectory();
    var woodbird = 'WoodBird-MP3';
    var music = 'music';
    return p.join(docs.path, woodbird, music);
  }

  String getSongCachePath(String base) {
    return p.join(songsDir, base);
  }

  Uri getSongUri(String songPath) {
    return Uri.file(songPath);
  }

  Future<String> getArtDir() async {
    var docs = await getApplicationDocumentsDirectory();
    var woodbird = 'WoodBird-MP3';
    var art = 'art';
    return p.join(docs.path, woodbird, art);
  }

  String getArtCachePath(String base) {
    return p.join(artDir, base);
  }

  AudioInterface? _audioInterface;
  AudioInterface get audioInterface => _audioInterface ??= AudioInterface();
  String appTitle;

  ValueNotifier<AppBarData> appBarNotifier = ValueNotifier(AppBarData('WoodBird MP3'));
  String? navTitle;
  String get currentNavTitle {
    return navTitle ??= appBarNotifier.value.title;
  }

  set currentNavTitle(String newTitle) {
    navTitle = newTitle;
    AppBarData tmp = appBarNotifier.value.copy();
    tmp.title = newTitle;
    appBarNotifier.value = tmp;
  }

  //global app variables
  //final ValueNotifier<MaterialColor> themeNotifier = ValueNotifier(Colors.blue);
  final ValueNotifier<String> routeNotifier = ValueNotifier('/');
  final ValueNotifier<HideableFloatingActionData> floatingActionNotifier =
      ValueNotifier(HideableFloatingActionData(false));

  final ValueNotifier<bool> loadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double?> loadingProgressNotifier = ValueNotifier<double?>(0);

  late AudioHandler handler;
  late AudioSession session;

  //homepage
  final ValueNotifier<HomePageData> homePageStateNotifier = ValueNotifier(HomePageData(0, 0, 0));

  //theme
  MaterialColor get theme =>
      globals.themes[globals.themes.keys.toList()[homePageStateNotifier.value.theme]] ?? globals.themes['Blue']!;

  //controls list
  ValueNotifier<List<int>> controls = ValueNotifier([]);
  //vals
  ValueNotifier<bool> swapTrackBar = ValueNotifier(false);
  ValueNotifier<bool> darkMode = ValueNotifier(false);

  //songs list
  final ValueNotifier<List<AudioSource>> songsNotifier = ValueNotifier(<AudioSource>[]);

  //playlists
  final ValueNotifier<List<PlaylistData>> playlistsNotifier = ValueNotifier(<PlaylistData>[]);

  //albums
  final ValueNotifier<List<AlbumData>> albumsNotifier = ValueNotifier(<AlbumData>[]);

  final Map<String, ThemedPage Function(BuildContext)> routes = {
    //'/': (context) => HomePage(title: 'Home'),
    '/': (context) => SongsPage(title: 'Songs'),
    '/playlists': (context) => PlaylistsPage(title: 'Playlists'),
    '/albums': (context) => AlbumsPage(title: 'Albums'),
    '/settings': (context) => SettingsPage(title: 'Settings'),
  };

  AppBarTitleListener appBar = AppBarTitleListener();
  Flyout flyout = const Flyout();
  PageNav navigation = PageNav();

  Scaffold appScaffold() {
    return Scaffold(
      appBar: appBar,
      drawer: flyout,
      body: navigation,
      resizeToAvoidBottomInset: true,
    );
  }

  String currentRoute = '/';

  void setNavTitle([String? title]) {
    currentNavTitle = title ??= currentNavTitle;
  }

  Future<void> loadPageStates() async {
    //load homepage state
    print('loading states');
    await loadHomeState();

    //load songs
    await loadSongs();
    //load playlists
    await loadPlaylists();
    //load albums
    await loadAlbums();
  }

  Future<void> savePageStates() async {
    print('saving states');
    await saveHomeState();
  }

  Future<void> closeApp(BuildContext context) async {}

  Future<void> appCleanup() async {
    await savePageStates();
  }

  Future<void> loadHomeState() async {
    //get homepagestate db object
    var homeStateDB = await globals.db.getHomeState();

    //give default value if null
    homeStateDB ??= const HomePageStateDB(
      id: 1,
      theme: 0,
      color: 0xFF00FF00,
      controls: '[0,1,2,3,4]',
      swapTrack: false,
      darkMode: true,
    );

    //make sure data is valid
    if (homeStateDB.theme < 0 || homeStateDB.theme >= globals.themes.length) {
      homeStateDB = HomePageStateDB(
        id: 1,
        theme: 0,
        color: homeStateDB.color,
        controls: homeStateDB.controls,
        swapTrack: homeStateDB.swapTrack,
        darkMode: homeStateDB.darkMode,
      );
    }

    //settings vals
    controls.value = json.decode(homeStateDB.controls).cast<int>();
    swapTrackBar.value = homeStateDB.swapTrack;
    darkMode.value = homeStateDB.darkMode;
    print('darkMode: ${darkMode.value}');

    //theme vals
    globals.themes['Custom'] = ColorMaterializer.getMaterial(Color(homeStateDB.color));
    // themeNotifier.value =
    //     globals.themes[globals.themes.keys.toList()[homeStateDB.theme]] ??
    //         globals.themes['Blue']!;

    //home page state
    homePageStateNotifier.value = homePageStateNotifier.value.fromEntry(homeStateDB);
  }

  Future<void> saveHomeState() async {
    await globals.db.setHomeState(globals.app.homePageStateNotifier.value.getEntry());
  }

  Future<void> loadSongs() async {
    List<AudioSource> songs = <AudioSource>[];
    List<SongDataDB> songsDB = await globals.db.getAllSongs();
    print('got ${songsDB.length} songs from db');
    for (var song in songsDB) {
      // var newUri = p.join(songsDir, song.localPath);
      var songPath = getSongCachePath(song.localPath);
      print('loading from path: $songPath');

      var loadedSong = AudioSource.uri(
        getSongUri(songPath),
        tag: MediaItem(
          id: '${song.id}',
          artist: song.artist,
          album: song.album,
          title: song.title,
          artUri: Uri.parse(song.art),
        ),
      );
      print('loaded song info:\n${song.title}\n${song.localPath}\n${song.art}');
      songs.add(loadedSong);
    }
    songsNotifier.value = songs;
  }

  Future<void> loadPlaylists() async {
    print('loading playlists');
    List<PlaylistData> playlists = <PlaylistData>[];
    List<PlaylistDataDB> playlistsDB = await globals.db.getAllPlaylists();
    for (var list in playlistsDB) {
      playlists.add(PlaylistData(
        id: list.id,
        title: list.title,
        songOrder: json.decode(list.songOrder).cast<int>(),
        description: list.description,
        art: list.art,
      ));
    }
    playlistsNotifier.value = playlists;
  }

  Future<void> loadAlbums() async {
    print('loading albums');
    List<AlbumData> albums = [];
    List<AlbumDataDB> albumsDB = await globals.db.getAllAlbums();
    for (var album in albumsDB) {
      albums.add(AlbumData(
        title: album.title,
        songOrder: json.decode(album.songOrder).cast<int>(),
        artist: album.artist,
        description: album.description,
        art: album.art,
        id: album.id,
      ));
    }
    albumsNotifier.value = albums;
  }

  @override
  State<StatefulWidget> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  _BaseAppState() : super();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Unsupported Platform',
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
