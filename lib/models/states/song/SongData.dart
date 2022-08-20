import 'package:drift/src/runtime/data_class.dart' show DataClass, Value;
import 'package:just_audio/just_audio.dart' show AudioSource, UriAudioSource;
import 'package:just_audio_background/just_audio_background.dart'
    show MediaItem;
import 'package:test_project/models/AudioInterface.dart';

import '../../../globals.dart' show app, db;
import 'package:path/path.dart' as p;

import '../baseState.dart';
import '../../../database/database.dart';

class SongData extends BaseDataDB {
  SongData({
    required this.artist,
    required this.title,
    required this.localPath,
    this.album = '',
    this.art = '',
    this.id,
  });
  int? id;
  String art;
  String artist;
  String album;
  String title;
  String localPath;

  UriAudioSource get source => AudioSource.uri(
        app.getSongUri(app.getSongCachePath(localPath)),
        tag: MediaItem(
          id: '$id',
          artist: artist,
          album: album,
          title: title,
          artUri: Uri.parse(art),
        ),
      );

  @override
  SongData copy() {
    return SongData(
      id: id,
      artist: artist,
      album: album,
      title: title,
      localPath: localPath,
      art: art,
    );
  }

  static SongData fromDB(SongDataDB data) {
    return SongData(
        id: data.id,
        artist: data.artist,
        album: data.album,
        title: data.title,
        localPath: data.localPath,
        art: data.art);
  }

  static SongData fromSource(AudioSource source) {
    MediaItem tag = AudioInterface.getTag(source);
    print('got tag: \n${tag.id}\n${tag.title}\n${tag.artist}');
    var basename = ((source as UriAudioSource).uri.toFilePath());
    return SongData(
      id: int.tryParse(tag.id),
      artist: tag.artist ?? '',
      album: tag.album ?? '',
      title: tag.title,
      localPath: p.join(app.songsDir, basename),
      art: tag.artUri == null ? '' : tag.artUri!.toString(),
    );
  }

  @override
  SongData fromEntry(DataClass dataclass) {
    SongData data = dataclass as SongData;
    var copy = this.copy();
    copy.id = data.id;
    copy.artist = data.artist;
    copy.album = data.album;
    copy.title = data.title;
    copy.localPath = data.localPath;
    copy.art = data.art;
    return copy;
  }

  @override
  SongsCompanion getCompanion() {
    return SongsCompanion(
      artist: Value(artist),
      album: Value(album),
      title: Value(title),
      localPath: Value(localPath),
      art: Value(art),
    );
  }

  @override
  SongDataDB getEntry() {
    return SongDataDB(
      id: id!,
      artist: artist,
      album: album,
      title: title,
      localPath: localPath,
      art: art,
    );
  }

  @override
  Future<void> saveData() async {
    print('id before: $id');
    id ??= -1;
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
