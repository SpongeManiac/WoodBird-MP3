import 'dart:ffi';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:test_project/models/AudioInterface.dart';

class AudioHandlerCustom extends BaseAudioHandler with SeekHandler {
  AudioHandlerCustom(this._player);
  final AudioInterface _player;

  @override
  Future<void> play() async {
    //await _player.play();
  }

  @override
  Future<void> pause() async {
    //await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    //await _player.seek(position);
  }

  @override
  Future<void> stop() async {
    //await _player.stop();
  }

  @override
  Future<void> click([MediaButton? button]) async {
    switch (button) {
      case MediaButton.media:
        // TODO: Handle this case.
        print('media button');
        //await _player.togglePlay();
        break;
      case MediaButton.next:
        print('next pressed');
        //await _player.playNext();
        break;
      case MediaButton.previous:
        print('back pressed');
        //await _player.playPrev();
        break;
      case null:
        print('null button');
        break;
    }
  }
}
