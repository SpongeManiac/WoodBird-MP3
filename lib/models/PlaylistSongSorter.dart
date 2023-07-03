//import 'package:just_audio_background/just_audio_background.dart';

import 'dart:core';

import 'package:woodbirdmp3/database/database.dart';

class SongSorter {
  //PlaylistSongSorter({required this.songs, required this.order});

  static List<SongDataDB> sort(List<SongDataDB> songs, List<int> order) {
    print('Song order before sort: ${order.toString()}');
    print('Songs before sort: ${songs.map((s) => s.id).toList()}');
    //check if order is same length as songs
    if (songs.length != order.length) {
      //something is wrong
      return songs;
    }
    List<SongDataDB> sortedSongs = [];
    for (var item in order) {
      //find first song
      var songToSort = songs.where((s) => s.id == item).toList();
      if (songs.isEmpty) {
        //song does not exist in song list, ignore this item
        continue;
      } else {
        //remove song from song list
        songs.remove(songToSort[0]);
        //add song to sorted list
        sortedSongs.add(songToSort[0]);
      }
    }
    //print('Songs after: ${sortedSongs.map((s) => s.id).toList()}');

    return sortedSongs;
  }
}
