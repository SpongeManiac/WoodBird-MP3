import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:test_project/models/states/song/SongData.dart';
import '../globals.dart' show app;

class AudioInterface {
  AudioInterface();
  AudioPlayer get player => app.player;
  bool get playing => player.playing;
  ValueNotifier<bool> playingNotifier = ValueNotifier(false);
  ValueNotifier<SongData> currentSongNotifier =
      ValueNotifier(SongData('Select a song to start jamming!', '', '/'));

  Future<void> setCurrent(SongData song) async {
    await pause();
    await app.player.setUrl(song.localPath);
    currentSongNotifier.value = song;
  }

  Future<void> play([Future<void> Function()? postPlay]) async {
    //print('starting to play');
    //print('current: ${player.playing}');
    //print('notifier: ${playingNotifier.value}');
    player.play().then((value) async {
      print('post play');
      postPlay ??= () async {};
      await postPlay!();
    });
    print('played');
    //print('setting notifier');
    //print('current: ${player.playing}');
    //print('notifier: ${playingNotifier.value}');
    playingNotifier.value = playing;
    //print('notifier: ${playingNotifier.value}');
  }

  Future<void> pause([Future<void> Function()? postPause]) async {
    //print('starting to pause');
    //print('current: ${player.playing}');
    //print('notifier: ${playingNotifier.value}');
    player.pause().then(
      (value) async {
        print('post pause');
        postPause ??= () async {};
        await postPause!();
      },
    );
    //print('setting notifier');
    //print('current: ${player.playing}');
    //print('notifier: ${playingNotifier.value}');
    playingNotifier.value = playing;
    //print('notifier: ${playingNotifier.value}');
  }

  Future<void> togglePlay() async {
    if (playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> setPlay(bool play, [Future<void> Function()? postSet]) async {
    if (playing != play) {
      if (playing) {
        await pause(postSet);
      } else {
        await this.play(postSet);
      }
    }
  }

  Future<void> playSingle(SongData song) async {
    setCurrent(song);
    await play(
      () async {
        await pause();
      },
    );
  }
}
