import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:test_project/widgets/appBar.dart';

import '../database/database.dart';
import '../globals.dart' as globals;
import '../models/AudioInterface.dart';
import '../models/colorMaterializer.dart';
import '../models/states/pages/homePageData.dart';
import '../models/states/playlist/playlistData.dart';
import '../models/states/song/songData.dart';
import '../screens/homePage.dart';
import '../screens/settingsPage.dart';
import '../screens/pageNav.dart';
import '../screens/playlistsPage.dart';
import '../screens/songsPage.dart';
import '../screens/themedPage.dart';
import '../widgets/flyout/flyout.dart';
import '../widgets/hideableFloatingAction.dart';

class BaseApp extends StatefulWidget {
  BaseApp(
      {super.key,
      this.appTitle = 'WoodBird MP3',
      this.navTitle = 'WoodBird MP3'});

  // AudioPlayer? _player;
  // AudioPlayer get player => _player ??= AudioPlayer();
  AudioInterface? _audioInterface;
  AudioInterface get audioInterface => _audioInterface ??= AudioInterface();
  String appTitle;

  ValueNotifier<AppBarData> appBarNotifier =
      ValueNotifier(AppBarData('WoodBird MP3'));
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
  final ValueNotifier<MaterialColor> themeNotifier = ValueNotifier(Colors.blue);
  final ValueNotifier<String> routeNotifier = ValueNotifier('/');
  final ValueNotifier<HideableFloatingActionData> floatingActionNotifier =
      ValueNotifier(HideableFloatingActionData(false));

  late AudioHandler handler;
  late AudioSession session;

  //homepage
  final ValueNotifier<HomePageData> homePageStateNotifier =
      ValueNotifier(HomePageData(0, 0, 0));

  //songs list
  final ValueNotifier<List<AudioSource>> songsNotifier =
      ValueNotifier(<AudioSource>[]);

  //playlists
  final ValueNotifier<List<PlaylistData>> playlistsNotifier =
      ValueNotifier(<PlaylistData>[]);

  final Map<String, ThemedPage Function(BuildContext)> routes = {
    '/': (context) => HomePage(title: 'Home'),
    '/playlists': (context) => PlaylistsPage(title: 'Playlists'),
    '/settings': (context) => SettingsPage(title: 'Settings'),
    '/songs': (context) => SongsPage(title: 'Songs'),
  };

  AppBarTitleListener appBar = AppBarTitleListener();
  Flyout flyout = const Flyout();
  PageNav navigation = PageNav();

  Scaffold appScaffold() {
    return Scaffold(
      appBar: appBar,
      drawer: flyout,
      body: navigation,
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
    await loadPlaylists();
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
    homeStateDB ??=
        HomePageStateDB(id: 1, theme: 0, count: 0, color: 0xFF000000);
    if (homeStateDB.theme < 0 || homeStateDB.theme >= globals.themes.length) {
      homeStateDB = HomePageStateDB(
          id: 1, theme: 0, count: homeStateDB.count, color: homeStateDB.color);
    }
    //get homepagestate
    //print('getting & setting home state');
    print('db theme: ${homeStateDB.theme}');
    homePageStateNotifier.value =
        homePageStateNotifier.value.fromEntry(homeStateDB);
    var theme = ColorMaterializer.getMaterial(Color(homeStateDB.color));
    //set theme custom color
    print('custom color: $theme');
    globals.themes['Custom'] = theme;
    themeNotifier.value =
        globals.themes[globals.themes.keys.toList()[homeStateDB.theme]]!;
  }

  Future<void> saveHomeState() async {
    await globals.db
        .setHomeState(globals.app.homePageStateNotifier.value.getEntry());
  }

  Future<void> loadSongs() async {
    List<AudioSource> songs = <AudioSource>[];
    List<SongDataDB> songsDB = await globals.db.getAllSongs();
    for (var song in songsDB) {
      songs.add(AudioSource.uri(
        Uri.parse(song.localPath),
        tag: MediaItem(
          id: '${song.id}',
          title: song.name,
          artist: song.artist,
        ),
      ));
    }
    songsNotifier.value = songs;
  }

  Future<void> loadPlaylists() async {
    print('loading playlists');
    List<PlaylistData> playlists = <PlaylistData>[];
    List<PlaylistDataDB> playlistsDB = await globals.db.getAllPlaylists();
    for (var list in playlistsDB) {
      playlists.add(PlaylistData(
        name: list.name,
        description: list.description,
        art: list.art,
        id: list.id,
      ));
    }
    playlistsNotifier.value = playlists;
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
