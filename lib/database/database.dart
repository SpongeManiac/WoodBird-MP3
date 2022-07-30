import 'package:drift/drift.dart';
import 'package:test_project/models/states/playlist/playlistData.dart';

part 'database.g.dart';

//Page States
@DataClassName('HomePageStateDB')
class HomePageState extends Table {
  //only allow one entry in table
  IntColumn get id =>
      integer().autoIncrement().withDefault(const Constant(1))();
  //info to preload widget
  IntColumn get theme => integer().withDefault(const Constant(0))();
  IntColumn get count => integer().withDefault(const Constant(0))();
  IntColumn get color => integer().withDefault(const Constant(0xFF000000))();
}

// @DataClassName('SongPageStateDB')
// class SongPageState extends Table {
//   IntColumn get id =>
//     integer().autoIncrement().withDefault(const Constant(1))();

// }

// Data
@DataClassName('SongDataDB')
class Songs extends Table {
  // PrimaryKey
  IntColumn get id => integer().autoIncrement()();
  //Song data
  TextColumn get artist => text().withLength(min: 0, max: 128)();
  TextColumn get name => text().withLength(min: 0, max: 128)();
  // where the file is stored locally
  TextColumn get localPath => text().withLength(min: 0, max: 512)();
  TextColumn get art =>
      text().withLength(min: 0, max: 512).withDefault(const Constant(''))();
}

@DataClassName('PlaylistDataDB')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 0, max: 128)();
  TextColumn get description =>
      text().withLength(min: 0, max: 256).withDefault(const Constant(''))();
  TextColumn get art =>
      text().withLength(min: 0, max: 512).withDefault(const Constant(''))();
}

@DataClassName('AlbumDataDB')
class Albums extends Table {
  // PrimaryKey
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 0, max: 128)();
  // set default to empty description
  TextColumn get description =>
      text().withLength(min: 0, max: 256).withDefault(const Constant(''))();
  TextColumn get art =>
      text().withLength(min: 0, max: 512).withDefault(const Constant(''))();
}

@DataClassName('PlaylistSongDataDB')
class PlaylistSongs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlist => integer().references(Playlists, #id)();
  IntColumn get song => integer().references(Songs, #id)();
}

@DataClassName('AlbumSongDataDB')
class AlbumSongs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get album => integer().references(Albums, #id)();
  IntColumn get song => integer().references(Songs, #id)();
}

@DriftDatabase(tables: [
  HomePageState,
  Songs,
  Playlists,
  PlaylistSongs,
  Albums,
  AlbumSongs,
])
class SharedDatabase extends _$SharedDatabase {
  // we tell the database where to store the data with this constructor
  SharedDatabase(QueryExecutor e) : super(e);

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;

  Future<HomePageStateDB?> getHomeState() async {
    print('Getting Home State');
    return await (select(homePageState)
          ..where((tbl) => tbl.id.equals(1))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> setHomeState(HomePageStateDB state) async {
    print('Saving Home State');
    return into(homePageState).insertOnConflictUpdate(state);
  }

  //songs
  Future<bool> songExists(int id) async {
    if (id < 0) {
      return false;
    }
    var count = countAll(filter: songs.id.equals(id));
    var res = await (selectOnly(songs)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingle();
    if (res > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<SongDataDB?> getSongData(int id) async {
    return await (select(songs)
          ..where((tbl) => tbl.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> setSongData(SongsCompanion song) async {
    return into(songs).insertOnConflictUpdate(song);
  }

  Future<bool> updateSongData(SongDataDB song) async {
    return update(songs).replace(song);
  }

  Future<int> delSongData(SongDataDB song) async {
    print('deleting ${song.name}, index ${song.id}');
    return (delete(songs)..where((s) => s.id.equals(song.id))).go();
  }

  Future<List<SongDataDB>> getAllSongs() async {
    return await (select(songs)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  //playlists
  Future<bool> playlistExists(int id) async {
    if (id < 0) {
      return false;
    }
    var count = countAll(filter: playlists.id.equals(id));
    var res = await (selectOnly(playlists)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingle();
    if (res > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> setPlaylistData(PlaylistsCompanion companion) {
    return into(playlists).insertOnConflictUpdate(companion);
  }

  Future<bool> updatePlaylistData(PlaylistDataDB playlist) {
    return update(playlists).replace(playlist);
  }

  Future<int> delPlaylistData(PlaylistDataDB playlist) async {
    print('deleting ${playlist.name}, index ${playlist.id}');
    return (delete(playlists)..where((p) => p.id.equals(playlist.id))).go();
  }

  Future<List<SongDataDB>> getPlaylistSongs(PlaylistData playlist) {
    // var playlistQuery = select(playlists)
    //   ..where((tbl) => tbl.id.equals(playlist.id));
    //get songs from playlist
    final songsQuery = (select(playlistSongs).join(
      [
        innerJoin(
          songs,
          songs.id.equalsExp(playlistSongs.song),
        ),
      ],
    )..where(playlistSongs.playlist.equals(playlist.id)));

    final songList = songsQuery.get() as Future<List<SongDataDB>>;
    print(songList);

    //combine queries into one
    return songList;
  }
}
