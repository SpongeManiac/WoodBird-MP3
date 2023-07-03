import 'package:just_audio_background/just_audio_background.dart';

class MediaItemDB extends MediaItem {
  int databaseID;
  MediaItemDB(this.databaseID, {required super.id, required super.title});
}
