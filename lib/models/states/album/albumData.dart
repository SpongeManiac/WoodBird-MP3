import 'dart:convert';

import 'package:drift/src/runtime/data_class.dart';
import 'package:test_project/database/database.dart';

import '../baseState.dart';

class AlbumData extends BaseDataDB {
  AlbumData({
    required this.title,
    required this.songOrder,
    required this.artist,
    this.description = '',
    this.art = '',
    this.id,
  });

  int? id;
  String title;
  List<int> songOrder;
  String artist;
  String description;
  String art;

  @override
  AlbumData copy() {
    return AlbumData(
      title: title,
      songOrder: songOrder,
      artist: artist,
      description: description,
      art: art,
      id: id,
    );
  }

  @override
  AlbumData fromEntry(DataClass dataclass) {
    AlbumDataDB data = dataclass as AlbumDataDB;
    var copy = this.copy();
    copy.id = data.id;
    copy.title = data.title;
    copy.songOrder = json.decode(data.songOrder).cast<int>();
    copy.description = data.description;
    copy.art = data.art;
    return copy;
  }

  @override
  AlbumsCompanion getCompanion() {
    return AlbumsCompanion(
      id: id == null ? const Value.absent() : Value(id!),
    );
  }

  @override
  AlbumDataDB getEntry() {
    return AlbumDataDB(
      id: id!,
      title: title,
      songOrder: songOrder.toString(),
      artist: artist,
      description: description,
      art: art,
    );
  }

  @override
  Future<void> saveData() async {
    print('album id before: $id');
    id ??= -1;
    if (await db.albumExists(id!)) {
      print('Album exists, updating');
      await db.updateAlbumData(getEntry());
    } else {
      print('Album does not exist, upserting');
      id = await db.setAlbumData(getCompanion());
    }
    print('album id after: $id');
  }
}
