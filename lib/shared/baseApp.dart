import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:test_project/models/AudioInterface.dart';
import 'package:test_project/widgets/appBar.dart';

import '../database/database.dart';
import '../globals.dart' as globals;
import '../models/colorMaterializer.dart';
import '../models/states/home/homePageData.dart';
import '../models/states/song/SongData.dart';
import '../screens/homePage.dart';
import '../screens/pageNav.dart';
import '../screens/songPage.dart';
import '../screens/themedPage.dart';
import '../widgets/flyout/flyout.dart';
import '../widgets/hideableFloatingAction.dart';

class BaseApp extends StatefulWidget {
  BaseApp(
      {super.key,
      this.appTitle = 'WoodBird MP3',
      this.navTitle = 'WoodBird MP3'})
      : super();

  AudioPlayer? _player;
  AudioPlayer get player => _player ??= AudioPlayer();
  AudioInterface? _audioInterface;
  AudioInterface get audioInterface =>
      _audioInterface ??= AudioInterface(player);
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

  //homepage
  final ValueNotifier<HomePageData> homePageStateNotifier =
      ValueNotifier(HomePageData(0, 0, 0));

  //songs list
  final ValueNotifier<List<SongData>> songsNotifier =
      ValueNotifier(<SongData>[]);

  final Map<String, ThemedPage Function(BuildContext)> routes = {
    '/': (context) => HomePage(title: 'Home'),
    '/files': (context) => SongsPage(title: 'Songs'),
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
    print('custom color: ${theme}');
    globals.themes['Custom'] = theme;
    themeNotifier.value =
        globals.themes[globals.themes.keys.toList()[homeStateDB.theme]]!;
  }

  Future<void> saveHomeState() async {
    await globals.db
        .setHomeState(globals.app.homePageStateNotifier.value.getEntry());
  }

  Future<void> loadSongs() async {
    List<SongData> songs = <SongData>[];
    List<SongDataDB> songsDB = await globals.db.getAllSongs();
    for (var song in songsDB) {
      songs.add(SongData(
          artist: song.artist,
          name: song.name,
          localPath: song.localPath,
          id: song.id));
    }
    songsNotifier.value = songs;
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
