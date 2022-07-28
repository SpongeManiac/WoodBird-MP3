import 'package:drift/src/runtime/data_class.dart';
import 'package:just_audio/just_audio.dart';

import '../../../globals.dart' show app, db;
import '../baseState.dart';
import '../../../database/database.dart';

class SongData extends BaseDataDB {
  SongData({
    required this.artist,
    required this.name,
    required this.localPath,
    this.art = '',
    this.id,
  }) : super();
  int? id;
  String art;
  String artist;
  String name;
  String localPath;

  AudioSource get source => AudioSource.uri(Uri.file(localPath));

  @override
  SongData copy() {
    return SongData(artist: artist, name: name, localPath: localPath, id: id);
  }

  @override
  SongData fromEntry(DataClass dataclass) {
    SongData data = dataclass as SongData;
    var copy = this;
    copy.id = data.id;
    copy.artist = data.artist;
    copy.name = data.name;
    copy.localPath = data.localPath;
    copy.art = art;
    return copy;
  }

  @override
  SongsCompanion getCompanion() {
    return SongsCompanion(
        artist: Value(artist), name: Value(name), localPath: Value(localPath));
  }

  @override
  SongDataDB getEntry() {
    return SongDataDB(
        id: id!, artist: artist, localPath: localPath, name: name, art: art);
  }

  @override
  void saveData() async {
    id ??= -1;
    print('id before: $id');
    //check if id exists already
    if (await db.songExists(id!)) {
      print('song exists, updating');
      await db.updateSongData(getEntry());
    } else {
      print('Song does not exist, upserting');
      id = await db.setSongData(getCompanion());
    }
    print('id after: $id');
  }
}
