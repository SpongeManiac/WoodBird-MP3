import 'package:drift/src/runtime/data_class.dart';

import '../../../database/database.dart';
import '../baseState.dart';

class PlaylistData extends BaseDataDB {
  PlaylistData({
    required this.title,
    this.description = '',
    this.art = '',
    this.id,
  });
  int? id;
  String title;
  String description;
  String art;

  @override
  PlaylistData copy() {
    return PlaylistData(
      title: title,
      description: description,
      art: art,
      id: id,
    );
  }

  @override
  PlaylistData fromEntry(DataClass dataclass) {
    PlaylistData data = dataclass as PlaylistData;
    var copy = this.copy();
    copy.id = data.id;
    copy.title = data.title;
    copy.description = data.description;
    copy.art = data.art;
    return copy;
  }

  @override
  PlaylistsCompanion getCompanion() {
    return PlaylistsCompanion(
      title: Value(title),
      description: Value(description),
      art: Value(art),
    );
  }

  @override
  PlaylistDataDB getEntry() {
    return PlaylistDataDB(
      id: id!,
      title: title,
      description: description,
      art: art,
    );
  }

  @override
  Future<void> saveData() async {
    print('playlist id before: $id');
    id ??= -1;
    //check if id exists already
    if (await db.playlistExists(id!)) {
      print('Playlist exists, updating');
      await db.updatePlaylistData(getEntry());
    } else {
      print('Playlist does not exist, upserting');
      id = await db.setPlaylistData(getCompanion());
    }
    print('playlist id after: $id');
  }
}
