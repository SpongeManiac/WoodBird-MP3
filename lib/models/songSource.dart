import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';

import 'states/song/SongData.dart';

class SongSource extends AudioSource {
  SongSource() : super();

  final Random random = Random();

  List<SongData> songs = [];

  @override
  // TODO: implement sequence
  List<IndexedAudioSource> get sequence {
    List<IndexedAudioSource> indexedSongs = [];
    for (var song in songs) {
      indexedSongs.add(IndexedSongSource());
    }
    return indexedSongs;
  }

  @override
  // TODO: implement shuffleIndices
  List<int> get shuffleIndices {
    List<int> shuffled = [];
    var max = songs.length;
    for (int i = 0; i < max; i++) {
      shuffled.add(random.nextInt(max));
    }
    return shuffled;
  }
}

class IndexedSongSource extends IndexedAudioSource {
  IndexedSongSource();
}
