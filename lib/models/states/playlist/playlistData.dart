import 'dart:convert';

import 'package:drift/src/runtime/data_class.dart';

import '../../../database/database.dart';
import '../baseState.dart';

class PlaylistData extends BaseDataDB {
  PlaylistData({
    required this.title,
    required this.songOrder,
    this.description = '',
    this.art = '',
    this.id,
  });
  int? id;
  List<int> songOrder;
  String title;
  String description;
  String art;

  @override
  PlaylistData copy() {
    return PlaylistData(
      title: title,
      songOrder: songOrder,
      description: description,
      art: art,
      id: id,
    );
  }

  static PlaylistData fromDB(PlaylistDataDB data) {
    return PlaylistData(
      id: data.id,
      title: data.title,
      songOrder: json.decode(data.songOrder).cast<int>(),
      description: data.description,
      art: data.art,
    );
  }

  @override
  PlaylistData fromEntry(DataClass dataclass) {
    PlaylistDataDB data = dataclass as PlaylistDataDB;
    var copy = this.copy();
    copy.id = data.id;
    copy.title = data.title;
    copy.songOrder = json.decode(data.songOrder).cast<int>();
    copy.description = data.description;
    copy.art = data.art;
    return copy;
  }

  @override
  PlaylistsCompanion getCompanion() {
    //return getEntry().toCompanion(true);
    return PlaylistsCompanion(
        //id: id == null ? Value.absent() : Value(id!),
        songOrder: Value(songOrder.toString()),
        title: Value(title),
        description: Value(description),
        art: Value(art));
  }

  @override
  PlaylistDataDB getEntry() {
    return PlaylistDataDB(
      id: id!,
      songOrder: songOrder.toString(),
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
      id = await db.addPlaylistData(getCompanion());
    }
    print('playlist id after: $id');
  }
}
