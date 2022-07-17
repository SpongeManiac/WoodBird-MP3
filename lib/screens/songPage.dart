import 'dart:io';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' show basename;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:test_project/models/states/song/SongData.dart';

import '../widgets/appBar.dart';
import 'themedPage.dart';

class SongsPage extends ThemedPage {
  SongsPage({
    Key? key,
    required super.title,
  }) : super(key: key);

  @override
  State<SongsPage> createState() => _SongsPageState();

  @override
  Future<void> saveState() async {
    return;
  }

  Future<void> addSong() async {
    print('going to add song');
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, allowMultiple: true, allowedExtensions: ['mp3']);
    if (result != null) {
      print('got ${result.count} file(s)');
      List<SongData> list = List.from(app.songsNotifier.value);
      for (String? path in result.paths) {
        path ??= '-1';
        if (path == '-1') continue;
        File file = File(path);
        String base = basename(path);
        var split = base.split('.');
        var name = split.first;
        var ext = split.last;
        print(name);
        print(ext);
        //create song data
        SongData song = SongData('unknown', name, path);
        song.saveData();
        list.add(song);
        app.songsNotifier.value = list;
      }
    } else {
      print('null result');
    }
  }

  @override
  AppBarData getDefaultAppBar() {
    print('getting def app bar');
    return AppBarData(title, <Widget>[
      PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            Map<String, Future<void> Function()> choices =
                <String, Future<void> Function()>{
              'Add Song': () async {
                await addSong();
              },
              'Test 2': () async {},
            };
            Map<String, IconData> choiceIcon = <String, IconData>{
              'Add Song': Icons.folder,
              'Test 2': Icons.bug_report,
            };

            List<PopupMenuItem<String>> list = [];

            for (String val in choices.keys) {
              list.add(
                PopupMenuItem(
                    onTap: choices[val],
                    child: Row(
                      children: [
                        Icon(
                          choiceIcon[val],
                          color: Theme.of(context).primaryColor,
                        ),
                        Expanded(
                          child: Text(
                            val,
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    )),
              );
            }

            return list;
          }),
      // itemBuilder: (context) {
      //   return {'Test 1', 'Test 2'}.map((String choice) {
      //     return PopupMenuItem<String>(
      //       value: choice,
      //       child: Column(
      //         children: [
      //           const Icon(
      //             Icons.file_copy,
      //           ),
      //           Text(choice),
      //         ],
      //       ),
      //     );
      //   }).toList();
      //},
      //)
    ]);
  }
}

class _SongsPageState extends State<SongsPage> {
  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.app.songsNotifier,
      builder: (context, List<SongData> newSongs, _) {
        print('got songs: ${newSongs.toList()}');
        return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: newSongs.length,
                  itemBuilder: ((context, index) {
                    SongData song = newSongs[index];
                    return ListTile(
                      title: Text(song.name),
                      subtitle: Text(song.artist),
                    );
                  }),
                )));
      },
    );
  }
}
