import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:test_project/models/states/song/songData.dart';

class ConcatenatingSongDataSource extends ConcatenatingAudioSource {
  ConcatenatingSongDataSource(this.queueNotifier) : super(children: []);
  ValueNotifier<List<SongData>> queueNotifier;
  List<SongData> get queue => queueNotifier.value;

  void updateQueue([List<SongData>? songs]) {
    songs ??= queue;
    print('updating concat queue');
    //children.clear();
    for (var song in queue) {
      if (!children.contains(song.source)) {
        children.add(song.source);
      }
    }
  }
}
