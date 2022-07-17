import 'package:drift/src/runtime/data_class.dart';

import '../baseState.dart';
import '../../../database/database.dart';

class SongData extends BaseDataDB {
  SongData(this.artist, this.name, this.localPath, [this.id]);
  int? id;
  String artist;
  String name;
  String localPath;

  @override
  SongData copy() {
    return SongData(artist, name, localPath, id);
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
