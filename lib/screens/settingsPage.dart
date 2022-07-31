import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:test_project/models/colorMaterializer.dart';
import '../globals.dart' as globals;
import 'package:test_project/screens/themedPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../models/states/pages/homePageData.dart';
import '../widgets/actionButtonLayout.dart';

class SettingsPage extends ThemedPage {
  SettingsPage({
    super.key,
    required super.title,
  }) : super();

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  @override
  Future<void> saveState() async {
    await globals.app.saveHomeState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final List<DropdownMenuItem<MaterialColor>> _themeDropdown = [];

  int _counter = 0;
  MaterialColor? _selectedItem = globals.themes['Blue'];
  HomePageData get state => globals.app.homePageStateNotifier.value;

  Color pickerColor = Colors.black;

  @override
  void initState() {
    super.initState();
    //init action button
    widget.initFloatingAction(_incrementCounter, const Icon(Icons.add));
    //init this state
    widget.initState(context);

    //build themedropdown
    print('rebuilding dropdown list');
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

    loadState(state);
  }

  void loadState(HomePageData state) {
    //set state
    _selectedItem = globals.themes.values.elementAt(state.theme);
    pickerColor = Color(state.color);
    _counter = state.count;
  }

  void _incrementCounter() {
    _counter++;
    globals.app.homePageStateNotifier.value =
        HomePageData(state.theme, _counter, state.color);
  }

  Future<void> _themeChanged(MaterialColor? color) async {
    _selectedItem = color;
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
                        state.color = pickerColor.value;
                        state.theme = idx;
                        state.saveData();
                        widget.themeNotifier.value = mat;
                      });
                    },
                  ),
                ],
              );
            });
      } else {
        state.theme = idx;
        state.saveData();
        widget.themeNotifier.value = color;
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
        return ActionButtonLayout(
          actionButton: widget.floatingActionButton,
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    items: _themeDropdown,
                    value: _selectedItem,
                    onChanged: (MaterialColor? newval) {
                      _themeChanged(newval);
                    },
                    isExpanded: true,
                    buttonDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    buttonWidth: 300,
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
