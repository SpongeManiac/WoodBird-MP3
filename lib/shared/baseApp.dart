import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:test_project/widgets/appBar.dart';

import '../database/database.dart';
import '../globals.dart' as globals;
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
      ValueNotifier(HomePageData(0, 0));

  //songs list
  final ValueNotifier<List<SongData>> songsNotifier =
      ValueNotifier(<SongData>[]);

  final Map<String, ThemedPage Function(BuildContext)> routes = {
    '/': (context) => HomePage(title: 'Home'),
    '/files': (context) => SongsPage(title: 'Songs'),
  };

  Flyout flyout = const Flyout();
  PageNav navigation = PageNav();
  HideableFloatingAction floatingActionButton = const HideableFloatingAction();

  Scaffold appScaffold() {
    return Scaffold(
      appBar: AppBarTitleListener(),
      drawer: flyout,
      body: navigation,
      floatingActionButton: floatingActionButton,
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
    homeStateDB ??= HomePageStateDB(id: 1, theme: 0, count: 0);
    if (homeStateDB.theme < 0 || homeStateDB.theme >= globals.themes.length) {
      homeStateDB = HomePageStateDB(id: 1, theme: 0, count: homeStateDB.count);
    }
    //get homepagestate
    //print('getting & setting home state');
    homePageStateNotifier.value =
        homePageStateNotifier.value.fromEntry(homeStateDB);
    themeNotifier.value = globals.themes.values.elementAt(homeStateDB.theme);
  }

  Future<void> saveHomeState() async {
    await globals.db
        .setHomeState(globals.app.homePageStateNotifier.value.getEntry());
  }

  Future<void> loadSongs() async {
    List<SongData> songs = <SongData>[];
    List<SongDataDB> songsDB = await globals.db.getAllSongs();
    for (var song in songsDB) {
      songs.add(SongData(song.artist, song.name, song.localPath, song.id));
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
