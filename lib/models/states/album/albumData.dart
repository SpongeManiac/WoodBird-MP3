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

  static AlbumData fromDB(AlbumDataDB data) {
    return AlbumData(
      id: data.id,
      title: data.title,
      songOrder: json.decode(data.songOrder).cast<int>(),
      artist: data.artist,
      description: data.description,
      art: data.art,
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
        //id: id == null ? Value.absent() : Value(id!),
        songOrder: Value(songOrder.toString()),
        title: Value(title),
        artist: Value(artist),
        description: Value(description),
        art: Value(art));
  }

  @override
  AlbumDataDB getEntry() {
    return AlbumDataDB(
      id: id!,
      songOrder: songOrder.toString(),
      title: title,
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
      id = await db.addAlbumData(getCompanion());
    }
    print('album id after: $id');
  }
}
