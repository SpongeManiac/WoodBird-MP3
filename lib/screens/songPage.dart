import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      //allowMultiple: true,
    );
    if (result != null) {
      print('got ${result.count} file(s)');
      return;
    } else {
      print('null result');
      return;
    }
  }

  @override
  AppBarData getDefaultAppBar() {
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
    return const Center(child: Text('Song Page'));
  }
}
