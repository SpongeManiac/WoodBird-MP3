// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:woodbirdmp3/models/AudioHandlerCustom.dart';
import 'package:woodbirdmp3/models/states/song/SongData.dart';

// enum LoopMode {
//   shuffle,
//   consecutive,
//   single,
//   once,
// }

class AudioInterface {
  AudioInterface() {
    // player.processingStateStream.listen((state) async {
    //   switch (state) {
    //     case ProcessingState.completed:
    //       await onComplete();
    //       break;
    //     case ProcessingState.idle:
    //       await onIdle();
    //       break;
    //     case ProcessingState.loading:
    //       await onLoading();
    //       break;
    //     case ProcessingState.buffering:
    //       await onBuffering();
    //       break;
    //     case ProcessingState.ready:
    //       await onReady();
    //       break;
    //   }
    // });
    player.setLoopMode(LoopMode.all);
    player.setShuffleModeEnabled(false);
    player.setAudioSource(playlist);
    player.shuffle();

    () async {};
  }

  AudioPlayer player = AudioPlayer();
  ConcatenatingAudioSource playlist = ConcatenatingAudioSource(
    children: [],
  );

  Stream<PositionData> get positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      player.positionStream,
      player.bufferedPositionStream,
      player.durationStream,
      (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero));

  // Future<AudioHandler> makeHandler() async {
  //   var handler = await AudioService.init(
  //     builder: () => AudioHandlerCustom(this),
  //     config: const AudioServiceConfig(
  //       androidNotificationChannelId: 'com.example.woodbirdmp3.channel.audio',
  //       androidNotificationChannelName: 'Bluetooth',
  //       androidNotificationOngoing: true,
  //     ),
  //   );

  //   handler.playbackState.add(PlaybackState(
  //     controls: [
  //       MediaControl.skipToPrevious,
  //       if (playing) MediaControl.play else MediaControl.pause,
  //       MediaControl.skipToNext
  //     ],
  //     systemActions: const {MediaAction.seek},
  //     androidCompactActionIndices: [0, 1, 3],
  //     processingState: const {
  //       ProcessingState.idle: AudioProcessingState.idle,
  //       ProcessingState.loading: AudioProcessingState.loading,
  //       ProcessingState.buffering: AudioProcessingState.buffering,
  //       ProcessingState.ready: AudioProcessingState.ready,
  //       ProcessingState.completed: AudioProcessingState.completed,
  //     }[player.processingState]!,
  //     playing: false,
  //   ));
  //   return handler;
  // }

  bool get playing => player.playing;
  //bool get && ;
  ValueNotifier<bool> playingNotifier = ValueNotifier(false);
  SongData get emptyQueue => SongData(
        artist: 'to start jamming!',
        title: 'Select a song',
        localPath: '',
        album: '',
        art: '',
      );
  ValueNotifier<int> queueNotifier = ValueNotifier(0);

  static MediaItem getTag(AudioSource source) {
    return ((source as UriAudioSource).tag) as MediaItem;
  }

  Future<void> resetPlayer() async {
    playlist.clear();
    playlist = ConcatenatingAudioSource(children: []);
    player.setAudioSource(playlist);
    player.setLoopMode(LoopMode.all);
    player.setShuffleModeEnabled(false);
    queueNotifier.value = playlist.length;
  }

  //MediaItem get source => getTag();

  //ValueNotifier<AudioSource>? _currentNotifier;
  //ValueNotifier<AudioSource> get currentNotifier =>
  //    _currentNotifier ??= ValueNotifier(emptyQueue.source);
  // AudioSource get current {
  //   return currentNotifier.value;
  // }

  //set current(AudioSource val) {
  //add current to history
  //   history.insert(0, val);
  //   if (history.length > 10) {
  //     history.removeLast();
  //   }
  //_currentNotifier ??= ValueNotifier<AudioSource>(emptyQueue.source);
  //currentNotifier.value = val;
  //}

  // LoopMode loopMode = LoopMode.consecutive;
  // Random random = Random();
  // List<SongData> history = [];
  // int pos = 0;

  // Future<void> Function() onBuffering = () async {};
  // Future<void> Function() onLoading = () async {};
  // Future<void> Function() onReady = () async {};
  // Future<void> Function() onIdle = () async {};
  // Future<void> Function() onComplete = () async {};
  // Future<void> Function() onCompleteNext() {
  //   print('getting oncomplete next');
  //   return () async {
  //     print('completed audio');
  //     print('play next complete');
  //     print('playing next');
  //     await playNext();
  //   };
  // }

  // Future<void> Function() onCompleteSingle() {
  //   print('getting oncomplete single');
  //   return () async {
  //     print('completed audio');
  //     print('play single complete');
  //     print('pausing');
  //     await pause();
  //   };
  // }

  // Future<void> Function() postPlay = () async {};
  // Future<void> Function() postPause = () async {};

  // setSource(SongData song) {
  //   if (song.localPath != emptyQueue.localPath) {
  //     player.setAudioSource(song.source);
  //   }
  // }

  // Future<void> setCurrentInt(int song) async {
  //   await pause();
  //   print('setting current by int: $song');
  //   var dif = (copy.length - 1) - song;
  //   if (dif > -1 && dif < copy.length) {
  //     //valid index
  //     SongData tmp = copy[song];
  //     //print('song name: ${tmp.name}');
  //     current = tmp;
  //     setSource(tmp);
  //   } else {
  //     current = emptyQueue;
  //   }
  // }

  // //preserves continuity in playing or not playing
  // Future<void> setCurrentIntCont(int song) async {
  //   bool wasPlaying = false;
  //   if (playing) {
  //     wasPlaying = true;
  //     await pause();
  //   }
  //   var dif = (copy.length - 1) - song;
  //   if (dif > -1 && dif < copy.length) {
  //     //valid index
  //     SongData tmp = copy[song];
  //     //print('song name: ${tmp.name}');
  //     current = tmp;
  //     setSource(tmp);
  //   } else {
  //     current = emptyQueue;
  //     setSource(emptyQueue);
  //   }
  //   if (wasPlaying) {
  //     await play();
  //   }
  // }

  // Future<void> setCurrent(SongData song) async {
  //   await pause();
  //   print('setting current by song');
  //   current = song;
  //   setSource(song);
  // }

  // Future<void> setCurrentAndPlay(SongData song) async {
  //   await pause();
  //   print('setting current by song');
  //   current = song;
  //   setSource(song);
  //   await play();
  // }

  // Future<void> setCurrentCont(SongData song) async {
  //   bool wasPlaying = false;
  //   if (playing) {
  //     wasPlaying = true;
  //     await pause();
  //   }
  //   if (song != emptyQueue) {
  //     current = song;
  //     setSource(song);
  //     if (wasPlaying) {
  //       await play();
  //     }
  //   }
  // }

  // Future<void> seek(Duration position) async {}

  // Future<void> play([Future<void> Function()? postPlay]) async {
  //   print('playing');
  //   player.play().then((value) async {
  //     //print('post play');
  //     postPlay ??= this.postPlay;
  //     await postPlay!();
  //   });
  //   print('played');
  //   playingNotifier.value = playing;
  // }

  // Future<void> pause([Future<void> Function()? postPause]) async {
  //   print('pausing');
  //   player.pause().then(
  //     (value) async {
  //       //print('post pause');
  //       postPause ??= this.postPause;
  //       await postPause!();
  //     },
  //   );
  //   print('paused');
  //   playingNotifier.value = playing;
  // }

  // Future<void> stop() async {
  //   await player.stop();
  // }

  // Future<void> cycleLoopMode() async {
  //   //LoopMode newMode;
  //   switch (loopMode) {
  //     case LoopMode.shuffle:
  //       loopMode = LoopMode.consecutive;
  //       break;
  //     case LoopMode.consecutive:
  //       loopMode = LoopMode.single;
  //       break;
  //     case LoopMode.single:
  //       loopMode = LoopMode.once;
  //       break;
  //     case LoopMode.once:
  //       loopMode = LoopMode.shuffle;
  //       break;
  //   }
  // }

  // Future<void> insert(int index, SongData song) async {
  //   print('begin insert');
  //   var tmp = copy;
  //   if (tmp.isEmpty || index == tmp.length) {
  //     print('adding item instead of inserting');
  //     tmp.add(song);
  //   } else if ((tmp.length - 1) - index > -1) {
  //     print('inserting');
  //     tmp.insert(index, song);
  //   }
  //   queueNotifier.value = tmp;
  // }

  // Future<void> replace(int index, SongData song) async {
  //   // will not add song if index does not exist
  //   var tmp = copy;
  //   if ((tmp.length - 1) - index >= 0) {
  //     tmp[index] = song;
  //     queueNotifier.value = tmp;
  //   }
  // }

  // Future<int> nextSong() async {
  //   int idx = copy.indexOf(current);
  //   int length = copy.length;
  //   int newIdx = idx;
  //   if (pos <= 0) {
  //     pos = 0;
  //     if (length > 0) {
  //       switch (loopMode) {
  //         case LoopMode.shuffle:
  //           newIdx = random.nextInt(length);
  //           break;
  //         case LoopMode.consecutive:
  //           newIdx = (idx + 1) % length;
  //           //print('idx+1: ${idx + 1}, length: $length, mod: $newIdx');
  //           break;
  //         case LoopMode.once:
  //           newIdx = (idx + 1) % length;
  //           if (newIdx == 0) {
  //             newIdx = -1;
  //           }
  //           break;
  //         case LoopMode.single:
  //           break;
  //       }
  //     }
  //   } else {
  //     newIdx = pos - 1;
  //   }
  //   return newIdx;
  // }

  // Future<int> prevSong() async {
  //   int idx = copy.indexOf(current);
  //   int length = copy.length;
  //   int newIdx = idx;
  //   if (pos <= 0) {
  //     pos = 0;
  //     if (length > 0) {
  //       switch (loopMode) {
  //         case LoopMode.shuffle:
  //           if (pos < copy.length - 1) {
  //             pos++;
  //           }
  //           break;
  //         case LoopMode.consecutive:
  //           newIdx = (idx - 1) % length;
  //           //print('idx+1: ${idx + 1}, length: $length, mod: $newIdx');
  //           break;
  //         case LoopMode.once:
  //           newIdx = (idx - 1) % length;
  //           if (newIdx == 0) {
  //             newIdx = -1;
  //           }
  //           break;
  //         case LoopMode.single:
  //           newIdx = idx;
  //           break;
  //       }
  //     }
  //   } else {
  //     //traversing history
  //     if (pos < copy.length - 1) {
  //       pos++;
  //     }
  //   }
  //   return newIdx;
  // }

  // Future<void> addToQueue(SongData song) async {
  //   // var newOnComplete = onCompleteNext();
  //   // if (onComplete != newOnComplete) {
  //   //   onComplete = newOnComplete;
  //   // }
  //   onComplete = onCompleteNext();
  //   var tmp = copy;
  //   tmp.add(song);
  //   queueNotifier.value = tmp;
  //   if (copy.length == 1) {
  //     await setCurrentCont(song);
  //   }
  // }

  // Future<void> playQueue() async {
  //   // var newOnComplete = onCompleteNext();
  //   // if (onComplete != newOnComplete) {
  //   //   onComplete = newOnComplete;
  //   // }
  //   onComplete = onCompleteNext();
  //   if (!playing) {
  //     print('playing queue');
  //     await play();
  //   } else {
  //     print('not playing queue');
  //   }
  // }

  // Future<void> playNext() async {
  //   await setCurrentIntCont(await nextSong());
  //   print('next song is: ${current.name} - ${current.artist}');
  // }

  // Future<void> playPrev() async {
  //   await setCurrentIntCont(await prevSong());
  //   print('prev song is: ${current.name} - ${current.artist}');
  // }

  // Future<void> playSingle(SongData song) async {
  //   var tmp = copy;
  //   tmp.clear();
  //   tmp.add(song);
  //   queueNotifier.value = tmp;
  //   // var newOnComplete = onCompleteSingle();
  //   // if (onComplete != newOnComplete) {
  //   //   onComplete = newOnComplete;
  //   // }
  //   onComplete = onCompleteSingle();
  //   await setCurrentCont(song);
  // }

  // void move(int oldIndex, int newIndex) {
  //   if (oldIndex != newIndex) {
  //     bool oldLarger = oldIndex > newIndex;
  //     //newIndex--;
  //     if (!oldLarger) {
  //       //print('adjusting newIndex: $newIndex');
  //       newIndex--;
  //       //print('new: $newIndex');
  //     }
  //     //print('moving $oldIndex to $newIndex');
  //     var tmp = copy;
  //     var maxLength = tmp.length - 1;
  //     //print('max length: $maxLength');
  //     SongData song = tmp[oldIndex];
  //     if (newIndex >= maxLength) {
  //       //print('moving song to end. Just adding');
  //       tmp.add(song);
  //     } else {
  //       if (oldLarger) {
  //         //print('new oldIndex: $oldIndex');
  //         oldIndex++;
  //         //print('inserting @ $newIndex');
  //         //print('before:');
  //         //printList(tmp);
  //         tmp.insert(newIndex, song);
  //         //print('after:');
  //         //printList(tmp);
  //       } else {
  //         //print('shifting');
  //         newIndex++;
  //         //print('inserting @ $newIndex');
  //         //print('before:');
  //         //printList(tmp);
  //         tmp.insert(newIndex, song);
  //         //print('after:');
  //         //printList(tmp);
  //       }
  //     }
  //     print('removing old');
  //     tmp.removeAt(oldIndex);
  //     queueNotifier.value = tmp;
  //   }
  // }

  // Future<void> moveToTop(SongData song) async {
  //   move(copy.indexOf(song), 0);
  // }

  // Future<void> moveToEnd(SongData song) async {
  //   move(copy.indexOf(song), copy.length);
  // }

  // Future<void> moveUp(SongData song) async {
  //   var tmp = copy;
  //   var idx = tmp.indexOf(song);
  //   var newIdx = idx - 1;
  //   if (newIdx < 0) {
  //     newIdx = 0;
  //   }
  //   if (newIdx >= tmp.length) {
  //     newIdx = tmp.length - 1;
  //   }

  //   move(idx, newIdx);
  // }

  // Future<void> moveDown(SongData song) async {
  //   var tmp = copy;
  //   var idx = tmp.indexOf(song);
  //   var newIdx = idx - 2;
  //   if (newIdx < 1) {
  //     newIdx = 1;
  //   }
  //   if (newIdx > tmp.length) {
  //     newIdx = tmp.length;
  //   }

  //   move(idx, newIdx);
  // }

  // void printQueue() {
  //   String list = '[';
  //   for (var song in copy) {
  //     list += '${song.name}\n';
  //   }
  //   list += ']';
  //   print(list);
  // }

  // void printList(List<SongData> list) {
  //   String result = '[';
  //   for (var song in list) {
  //     result += '${song.name}\n';
  //   }
  //   result += ']';
  //   print(result);
  // }

  AudioSource? getCurrent() {
    int idx = player.currentIndex ?? -1;
    if (idx < 0) {
      return emptyQueue.source;
    } else {
      return playlist[idx];
    }
  }

  Future<void> setCurrent(int song) async {
    if (song < 0 || song > playlist.children.length - 1) {
      print('Out of bounds queue index: $song');
      return;
    }
    player.seek(const Duration(seconds: 0), index: song);
  }

  Future<void> togglePlay() async {
    print('playing: $playing');
    AudioSource current = player.currentIndex == null ? emptyQueue.source : playlist[player.currentIndex!];
    if (playlist.children.isNotEmpty && current != emptyQueue.source) {
      if (playing) {
        await player.pause();
      } else {
        print('playing');
        player.play();
      }
    } else {
      await player.pause();
    }
    playingNotifier.value = playing;
  }

  // Future<void> add(AudioSource song) async {
  //   playlist.add(song);
  //   await player.shuffle();
  //   queueNotifier.value = playlist.length;
  // }

  Future<void> move(int currentIdx, int newIdx) async {
    if (currentIdx < newIdx) {
      newIdx--;
    }
    print('moving $currentIdx to $newIdx');
    playlist.move(currentIdx, newIdx);
    queueNotifier.value = playlist.length;
  }

  static List<T> moveGeneric<T>(List<T> list, int oldIndex, int newIndex) {
    if (oldIndex != newIndex) {
      bool oldLarger = oldIndex > newIndex;
      //newIndex--;
      if (!oldLarger) {
        //print('adjusting newIndex: $newIndex');
        newIndex--;
        //print('new: $newIndex');
      }
      //print('moving $oldIndex to $newIndex');
      var tmp = List.of(list);
      var maxLength = tmp.length - 1;
      //print('max length: $maxLength');
      T itm = tmp[oldIndex];
      if (newIndex >= maxLength) {
        //print('moving song to end. Just adding');
        tmp.add(itm);
      } else {
        if (oldLarger) {
          //print('new oldIndex: $oldIndex');
          oldIndex++;
          //print('inserting @ $newIndex');
          //print('before:');
          //printList(tmp);
          tmp.insert(newIndex, itm);
          //print('after:');
          //printList(tmp);
        } else {
          //print('shifting');
          newIndex++;
          //print('inserting @ $newIndex');
          //print('before:');
          //printList(tmp);
          tmp.insert(newIndex, itm);
          //print('after:');
          //printList(tmp);
        }
      }
      print('removing old');
      tmp.removeAt(oldIndex);
      return tmp;
    }
    return [];
  }

  Future<void> moveUp(AudioSource song) async {
    var idx = playlist.children.indexOf(song);
    if (idx > 0) {
      move(idx, idx - 1);
    }
  }

  Future<void> moveUpIdx(int idx) async {
    if (idx > 0) {
      move(idx, idx - 1);
    }
  }

  Future<void> moveDown(AudioSource song) async {
    var idx = playlist.children.indexOf(song);
    var last = playlist.children.length - 1;
    if (idx < last) {
      move(idx, idx + 2);
    }
  }

  Future<void> moveDownIdx(int idx) async {
    var last = playlist.children.length - 1;
    if (idx < last) {
      move(idx, idx + 2);
    }
  }

  Future<void> moveTop(AudioSource song) async {
    var idx = playlist.children.indexOf(song);
    if (idx != 0) {
      move(idx, 0);
    }
  }

  Future<void> moveTopIdx(int idx) async {
    if (idx != 0) {
      move(idx, 0);
    }
  }

  Future<void> moveEnd(AudioSource song) async {
    var idx = playlist.children.indexOf(song);
    var last = playlist.children.length - 1;
    if (idx != last) {
      move(idx, last + 1);
    }
  }

  Future<void> moveEndIdx(int idx) async {
    var last = playlist.children.length - 1;
    if (idx != last) {
      move(idx, last + 1);
    }
  }

  Future<void> remove(AudioSource song) async {
    var tag = getTag(song);
    var idx = playlist.children.indexOf(song);
    print('removing ${tag.title} from queue with idx of $idx');
    // if (player.currentIndex == playlist.children.indexOf(song)) {
    //   await player.removeA;
    playlist.removeAt(idx);
    queueNotifier.value = playlist.length;
    // }
  }

  Future<void> removeIdx(int idx) async {
    //var tag = getTag(song);
    //var idx = playlist.children.indexOf(song);
    //print('removing ${tag.title} from queue with idx of $idx');
    // if (player.currentIndex == playlist.children.indexOf(song)) {
    //   await player.removeA;
    playlist.removeAt(idx);
    queueNotifier.value = playlist.length;
    // }
  }

  Future<void> removeAll() async {
    while (playlist.children.isNotEmpty) {
      remove(playlist.children[0]);
    }
  }

  Future<void> setQueue(List<AudioSource> songs) async {
    playlist.clear();
    await addToQueue(songs);
    player.seek(const Duration(seconds: 0), index: songs.indexOf(songs.first));
  }

  Future<void> addToQueue(List<AudioSource> songs) async {
    await playlist.addAll(songs);
    queueNotifier.value = playlist.length;
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
