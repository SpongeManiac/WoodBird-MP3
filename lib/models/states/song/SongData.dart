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
    this.id,
  }) : super();
  int? id;
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
    return copy;
  }

  @override
  SongDataDB getEntry() {
    return SongDataDB(
        id: id!, artist: artist, localPath: localPath, name: name);
  }

  @override
  void saveData() async {
    id = await db.setSongData(getCompanion());
  }

  @override
  SongsCompanion getCompanion() {
    return SongsCompanion(
        artist: Value(artist), name: Value(name), localPath: Value(localPath));
  }
}
