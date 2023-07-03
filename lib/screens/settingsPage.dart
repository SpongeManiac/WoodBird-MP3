import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:woodbirdmp3/models/colorMaterializer.dart';
import '../globals.dart' as globals;
import 'package:woodbirdmp3/screens/themedPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../models/states/pages/homePageData.dart';

class SettingsPage extends ThemedPage {
  SettingsPage({
    super.key,
    required super.title,
  }) : super();

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  @override
  void initState(BuildContext context) {
    super.initState(context);
    setAndroidBack(
      context,
      () async {
        app.navigation.goto(context, '/');
        return false;
      },
      Icons.home_rounded,
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final List<DropdownMenuItem<MaterialColor>> _themeDropdown = [];

  int _counter = 0;
  MaterialColor? _selectedItem = globals.themes['Blue'];

  HomePageData get copy => globals.app.homePageStateNotifier.value.copy();
  set copy(newVal) {
    widget.app.homePageStateNotifier.value = newVal;
  }

  Color pickerColor = Colors.green;

  @override
  void initState() {
    super.initState();
    //init this state
    widget.initState(context);

    //build themedropdown
    //print('rebuilding dropdown list');
    for (var theme in globals.themes.keys) {
      MaterialColor color = globals.themes[theme]!;
      print('adding theme: $theme, ${globals.themes[theme]!.value}');
      _themeDropdown.add(
        DropdownMenuItem(
          value: color,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 50),
            child: Center(
              child: Text(
                theme,
                style: TextStyle(color: color),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

      pickerColor = globals.themes['Custom']!;
    }

    loadState(copy);
  }

  void loadState(HomePageData state) {
    //set state
    _selectedItem = globals.themes.values.elementAt(state.theme);
    pickerColor = Color(state.color);
    _counter = state.count;
  }

  Future<void> _themeChanged(MaterialColor? color) async {
    _selectedItem = color;
    var tmp = copy;
    if (color != null) {
      var idx = globals.themes.values.toList().indexOf(color);
      if (idx == 5) {
        //user chose custom color, show the color picker
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Select a color'),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (color) {
                      pickerColor = color;
                    },
                  ),
                ),
                actions: [
                  ElevatedButton(
                    child: const Text('Done'),
                    onPressed: () {
                      print('custom color: ${pickerColor.value}');
                      var mat = ColorMaterializer.getMaterial(pickerColor);
                      setState(() {
                        //print('themes before:');
                        print(globals.themes.values);
                        globals.themes['Custom'] = mat;
                        //print('themes after:');
                        //print(globals.themes.values);
                        _themeDropdown[idx] = DropdownMenuItem(
                          value: mat,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 50),
                            child: Center(
                              child: Text(
                                'Custom',
                                style: TextStyle(color: mat),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                        tmp.color = pickerColor.value;
                        tmp.theme = idx;

                        copy = tmp;
                      });
                    },
                  ),
                ],
              );
            });
      } else {
        tmp.theme = idx;
        copy = tmp;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: globals.app.homePageStateNotifier,
      builder: (context, HomePageData newState, _) {
        //HomePageData newState = newStateUncasted;
        newState.saveData();
        loadState(newState);
        // This method is rerun every time setState is called, for instance as done
        // by the _incrementCounter method above.
        //
        // The Flutter framework has been optimized to make rerunning build methods
        // fast, so that you can just rebuild anything that needs updating rather
        // than having to individually change instances of widgets.
        return Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Theme Color'),
                        subtitle: const Text('Set the color of the app\'s theme.'),
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            items: _themeDropdown,
                            value: _selectedItem,
                            onChanged: (MaterialColor? newval) {
                              _themeChanged(newval);
                            },
                            isExpanded: true,
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              width: 250,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Swap SeekBar & Controls'),
                        subtitle: const Text('Swap the seekbar and player controls.'),
                        value: widget.app.swapTrackBar.value,
                        onChanged: (newVal) {
                          var tmp = copy;
                          widget.app.swapTrackBar.value = newVal;
                          //update state
                          tmp.swapTrack = newVal;
                          copy = tmp;
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Nocturnal Friendly.'),
                        value: widget.app.darkMode.value,
                        onChanged: (newVal) {
                          var tmp = copy;
                          widget.app.darkMode.value = newVal;
                          //update state
                          tmp.darkMode = newVal;
                          copy = tmp;
                        },
                      ),
                      ListTile(
                        title: const Text('Reset Player'),
                        subtitle: const Text('Resets the audio player. Usually fixes playback issues.'),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            await widget.app.audioInterface.resetPlayer();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
