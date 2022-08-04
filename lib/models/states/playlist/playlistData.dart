import 'package:drift/src/runtime/data_class.dart';

import '../../../database/database.dart';
import '../baseState.dart';

class PlaylistData extends BaseDataDB {
  PlaylistData({
    required this.name,
    this.description = '',
    this.art = '',
    this.id,
  });
  int? id;
  String name;
  String description;
  String art;

  @override
  PlaylistData copy() {
    return PlaylistData(name: name, description: description, art: art, id: id);
  }

  @override
  PlaylistData fromEntry(DataClass dataclass) {
    PlaylistData data = dataclass as PlaylistData;
    var copy = this.copy();
    copy.id = data.id;
    copy.name = data.name;
    copy.description = data.description;
    copy.art = data.art;
    return copy;
  }

  @override
  PlaylistsCompanion getCompanion() {
    return PlaylistsCompanion(
      name: Value(name),
      description: Value(description),
      art: Value(art),
    );
  }

  @override
  PlaylistDataDB getEntry() {
    return PlaylistDataDB(
      id: id!,
      name: name,
      description: description,
      art: art,
    );
  }

  @override
  Future<void> saveData() async {
    print('id before: $id');
    id ??= -1;
    //check if id exists already
    if (await db.playlistExists(id!)) {
      print('Playlist exists, updating');
      await db.updatePlaylistData(getEntry());
    } else {
      print('Playlist does not exist, upserting');
      id = await db.setPlaylistData(getCompanion());
    }
    print('id after: $id');
  }
}
