import 'package:drift/src/runtime/data_class.dart';
import 'package:test_project/database/database.dart';

import '../baseState.dart';

class AlbumData extends BaseDataDB {
  AlbumData({
    required this.title,
    required this.artist,
    this.description = '',
    this.art = '',
    this.id,
  });

  int? id;
  String title;
  String artist;
  String description;
  String art;

  @override
  AlbumData copy() {
    return AlbumData(
      title: title,
      artist: artist,
      description: description,
      art: art,
      id: id,
    );
  }

  @override
  AlbumData fromEntry(DataClass dataclass) {
    AlbumData data = dataclass as AlbumData;
    var copy = this.copy();
    copy.id = data.id;
    copy.title = data.title;
    copy.description = data.description;
    copy.art = data.art;
    return copy;
  }

  @override
  AlbumsCompanion getCompanion() {
    return AlbumsCompanion(
        title: Value(title),
        artist: Value(artist),
        description: Value(description),
        art: Value(art));
  }

  @override
  AlbumDataDB getEntry() {
    return AlbumDataDB(
      id: id!,
      title: title,
      artist: artist,
      description: description,
      art: art,
    );
  }

  @override
  Future<void> saveData() async {
    id ??= -1;
    if (await db.albumExists(id!)) {
      await db.updateAlbumData(getEntry());
    } else {
      id = await db.setAlbumData(getCompanion());
    }
  }
}
