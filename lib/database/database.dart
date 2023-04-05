import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:test_project/models/PlaylistSongSorter.dart';
import 'package:test_project/models/states/playlist/playlistData.dart';
import 'package:test_project/models/states/song/songData.dart';

import '../models/states/album/albumData.dart';

part 'database.g.dart';

//Page States
@DataClassName('HomePageStateDB')
class HomePageState extends Table {
  //only allow one entry in table
  IntColumn get id =>
      integer().autoIncrement().withDefault(const Constant(1))();
  //info to preload widget
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  BoolColumn get swapTrack => boolean().withDefault(const Constant(false))();
  IntColumn get theme => integer().withDefault(const Constant(0))();
  //IntColumn get count => integer().withDefault(const Constant(0))();
  IntColumn get color => integer().withDefault(const Constant(0xFF000000))();
  TextColumn get controls => text()
      .withDefault(const Constant('[0, 1, 2, 3, 4]'))
      .withLength(min: 10, max: 20)();
  //BoolColumn get
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
  TextColumn get album => text().withLength(min: 0, max: 128)();
  TextColumn get title => text().withLength(min: 0, max: 128)();
  // where the file is stored locally
  TextColumn get localPath => text().withLength(min: 0, max: 1024)();
  TextColumn get art =>
      text().withLength(min: 0, max: 1024).withDefault(const Constant(''))();
}

@DataClassName('PlaylistDataDB')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 0, max: 128)();
  TextColumn get songOrder => text().withLength(min: 0, max: 2048)();
  TextColumn get description =>
      text().withLength(min: 0, max: 1024).withDefault(const Constant(''))();
  TextColumn get art =>
      text().withLength(min: 0, max: 1024).withDefault(const Constant(''))();
}

@DataClassName('AlbumDataDB')
class Albums extends Table {
  // PrimaryKey
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 0, max: 128)();
  TextColumn get songOrder => text().withLength(min: 0, max: 2048)();
  TextColumn get artist => text().withLength(min: 0, max: 128)();
  // set default to empty description
  TextColumn get description =>
      text().withLength(min: 0, max: 1024).withDefault(const Constant(''))();
  TextColumn get art =>
      text().withLength(min: 0, max: 1024).withDefault(const Constant(''))();
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

//streams
@DataClassName('StreamDataDB')
class Streams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 0, max: 128)();
  TextColumn get description =>
      text().withLength(min: 0, max: 1024).withDefault(const Constant(''))();
  TextColumn get streamURL =>
      text().withLength(min: 0, max: 1024).withDefault(const Constant(''))();
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
    return await into(homePageState).insertOnConflictUpdate(state);
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
    if (res != null && res > 0) {
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
    print('deleting ${song.title}, index ${song.id}');
    return (delete(songs)..where((s) => s.id.equals(song.id))).go();
    //remove file?
  }

  Future<List<SongDataDB>> getAllSongs() async {
    return await (select(songs)
          ..orderBy([(t) => OrderingTerm(expression: t.title)]))
        .get();
  }

  //playlist
  Future<bool> playlistExists(int id) async {
    if (id < 0) {
      return false;
    }
    var count = countAll(filter: playlists.id.equals(id));
    var res = await (selectOnly(playlists)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingle();
    if (res != null && res > 0) {
      return true;
    } else {
      return false;
    }
  }

  //album
  Future<bool> albumExists(int id) async {
    if (id < 0) {
      return false;
    }
    var count = countAll(filter: albums.id.equals(id));
    var res = await (selectOnly(albums)..addColumns([count]))
        .map((row) => row.read(count))
        .getSingle();
    if (res != null && res > 0) {
      return true;
    } else {
      return false;
    }
  }

  //playlist
  Future<int> addPlaylistData(PlaylistsCompanion companion) async {
    int newId = await into(playlists).insert(companion);
    print('new id: $newId');
    return newId;
  }

  //album
  Future<int> addAlbumData(AlbumsCompanion companion) async {
    int newId = await into(albums).insert(companion);
    print('new id: $newId');
    return newId;
  }

  //playlist
  Future<PlaylistDataDB?> getPlaylistData(int id) async {
    return await (select(playlists)
          ..where((tbl) => tbl.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  //album
  Future<AlbumDataDB?> getAlbumData(int id) async {
    return await (select(albums)
          ..where((tbl) => tbl.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  //playlist
  Future<bool> updatePlaylistData(PlaylistDataDB playlist) async {
    print('Updating playlist: new songOrder: ${playlist.songOrder}');
    return await update(playlists).replace(playlist);
  }

  //album
  Future<bool> updateAlbumData(AlbumDataDB album) async {
    print('Updating playlist: new songOrder: ${album.songOrder}');
    return await update(albums).replace(album);
  }

  //playlist
  Future<int> delPlaylistData(PlaylistDataDB playlist) async {
    //get playlist relations
    var playlistSongs = await getPlaylistSongs(playlist);
    for (var song in playlistSongs) {
      await delPlaylistSong(playlist, song);
    }
    print('deleting ${playlist.title}, index ${playlist.id}');
    return await (delete(playlists)..where((p) => p.id.equals(playlist.id)))
        .go();
  }

  //album
  Future<int> delAlbumData(AlbumDataDB album) async {
    //get playlist relations
    var albumSongs = await getAlbumSongs(album);
    for (var song in albumSongs) {
      await delAlbumSong(album, song);
    }
    print('deleting ${album.title}, index ${album.id}');
    return await (delete(playlists)..where((p) => p.id.equals(album.id))).go();
  }

  //playlist
  Future<int> addPlaylistSong(PlaylistDataDB playlist, SongDataDB song) async {
    //add song into song order
    //List<int> songOrder = json.decode(playlist.songOrder).cast<int>();
    //print('songOrder before add: $songOrder');

    //songOrder.add(song.id);
    //print('songOrder after add: $songOrder');

    //copy current playlist
    //var newOrderPlaylist = PlaylistData.fromDB(playlist);
    //replace song order
    //newOrderPlaylist.songOrder = songOrder;
    //update playlist song order
    //var newOrderEntry = newOrderPlaylist.getEntry();
    //print('entry id: ${newOrderEntry.id}');
    //await updatePlaylistData(newOrderEntry);
    //print('songOrder after update: ${newOrderPlaylist.songOrder}');
    PlaylistSongsCompanion entry = PlaylistSongsCompanion(
      playlist: Value(playlist.id),
      song: Value(song.id),
    );
    return await into(playlistSongs).insert(entry);
  }

  //album
  Future<int> addAlbumSong(AlbumDataDB album, SongDataDB song) async {
    AlbumSongsCompanion entry = AlbumSongsCompanion(
      album: Value(album.id),
      song: Value(song.id),
    );
    return await into(albumSongs).insert(entry);
  }

  //playlist
  Future<int> delPlaylistSong(PlaylistDataDB playlist, SongDataDB song) async {
    //del song from song order
    //List<int> songOrder = json.decode(playlist.songOrder).cast<int>();
    //print('songOrder before del: $songOrder');
    //songOrder.remove(song.id);
    //print('songOrder after del: $songOrder');
    //replace song order
    //playlist = playlist.copyWith(songOrder: songOrder.toString());
    //update playlist song order
    //await updatePlaylistData(playlist);
    //print('songOrder after update: ${playlist.songOrder}');
    final firstSongID = selectOnly(playlistSongs)
      ..addColumns([playlistSongs.id])
      ..where(playlistSongs.playlist.equals(playlist.id) &
          playlistSongs.song.equals(song.id));
    return await (delete(playlistSongs)
          ..where((e) => e.id.equalsExp(subqueryExpression(firstSongID))))
        .go();
  }

  //album
  Future<int> delAlbumSong(AlbumDataDB album, SongDataDB song) async {
    final firstSongID = selectOnly(albumSongs)
      ..addColumns([albumSongs.id])
      ..where(
          albumSongs.album.equals(album.id) & albumSongs.song.equals(song.id));
    return await (delete(albumSongs)
          ..where((e) => e.id.equalsExp(subqueryExpression(firstSongID))))
        .go();
  }

  //playlist
  Future<List<SongDataDB>> getPlaylistSongs(PlaylistDataDB playlist) async {
    // var playlistQuery = select(playlists)
    //   ..where((tbl) => tbl.id.equals(playlist.id));
    //get songs from playlist
    List<int> songOrder = json.decode(playlist.songOrder).cast<int>();
    final songsQuery = await (select(playlistSongs).join(
      [
        leftOuterJoin(
          songs,
          songs.id.equalsExp(playlistSongs.song),
        ),
      ],
    )..where(playlistSongs.playlist.equals(playlist.id)))
        .get();

    var songsList = songsQuery.map((result) {
      return result.readTable(songs);
    }).toList();
    //sort songs into playlist order
    songsList = SongSorter.sort(songsList, songOrder);
    //..sort((a, b) => songOrder.indexOf(a.id) - songOrder.indexOf(b.id));
    //..sort((a, b) => a.id.compareTo(b.id));
    //final ref = {for (var e in songsList) e.id: e};
    //songsList = List.from(playlist.songOrder.map((id) => ref[id]));
    print('got ${songsList.length} songs in playlist');
    print('songOrder: ${playlist.songOrder}');
    return songsList;
  }

  //album
  Future<List<SongDataDB>> getAlbumSongs(AlbumDataDB album) async {
    List<int> songOrder = json.decode(album.songOrder).cast<int>();
    final songsQuery = await (select(albumSongs).join(
      [
        leftOuterJoin(
          songs,
          songs.id.equalsExp(albumSongs.song),
        ),
      ],
    )..where(albumSongs.album.equals(album.id)))
        .get();

    var songsList = songsQuery.map((result) {
      return result.readTable(songs);
    }).toList();
    //sort songs into playlist order
    songsList = SongSorter.sort(songsList, songOrder);
    return songsList;
  }

  //playlist
  Future<List<PlaylistDataDB>> getAllPlaylists() async {
    return await (select(playlists)
          ..orderBy([(t) => OrderingTerm(expression: t.title)]))
        .get();
  }

  //album
  Future<List<AlbumDataDB>> getAllAlbums() async {
    return await (select(albums)
          ..orderBy([(t) => OrderingTerm(expression: t.title)]))
        .get();
  }

  // Future<int> setAlbumData(AlbumsCompanion companion) async {
  //   int newId = await into(albums).insertOnConflictUpdate(companion);
  //   print('new id: $newId');
  //   //PlaylistsCompanion.insert(name: )
  //   return newId;
  // }

  // Future<bool> updateAlbumData(AlbumDataDB album) async {
  //   return await update(albums).replace(album);
  // }

  // Future<int> delAlbumData(AlbumDataDB album) async {
  //   print('deleting ${album.title}, index ${album.id}');
  //   return await (delete(albums)..where((p) => p.id.equals(album.id))).go();
  // }

  // Future<int> addAlbumSong(AlbumDataDB album, SongDataDB song) async {
  //   AlbumSongsCompanion entry = AlbumSongsCompanion(
  //     album: Value(album.id),
  //     song: Value(song.id),
  //   );
  //   return await into(albumSongs).insert(entry);
  // }

  // Future<int> delAlbumSong(AlbumDataDB album, SongDataDB song) async {
  //   final firstSongID = selectOnly(albumSongs)
  //     ..addColumns([albumSongs.id])
  //     ..where(
  //         albumSongs.album.equals(album.id) & albumSongs.song.equals(song.id));
  //   return await (delete(albumSongs)
  //         ..where((e) => e.id.equalsExp(subqueryExpression(firstSongID))))
  //       .go();
  // }

  // Future<List<SongDataDB>> getAlbumSongs(AlbumData album) async {
  //   // var playlistQuery = select(playlists)
  //   //   ..where((tbl) => tbl.id.equals(playlist.id));
  //   //get songs from playlist
  //   if (album.id == null) {
  //     return List.empty();
  //   }
  //   final songsQuery = await (select(albumSongs).join(
  //     [
  //       innerJoin(
  //         songs,
  //         songs.id.equalsExp(albumSongs.song),
  //       ),
  //     ],
  //   )..where(albumSongs.album.equals(album.id!)))
  //       .get();

  //   var songsList = songsQuery.map((result) {
  //     return result.readTable(songs);
  //   }).toList();
  //   print('got ${songsList.length} songs in playlist');
  //   return songsList;
  // }

  // Future<List<AlbumDataDB>> getAllAlbums() async {
  //   return await (select(albums)
  //         ..orderBy([(t) => OrderingTerm(expression: t.title)]))
  //       .get();
  // }
}
