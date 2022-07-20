import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:test_project/screens/themedPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../models/states/home/homePageData.dart';
import '../widgets/actionButtonLayout.dart';

class HomePage extends ThemedPage {
  HomePage({
    super.key,
    required super.title,
  }) : super();

  @override
  State<HomePage> createState() => _HomePageState();

  @override
  Future<void> saveState() async {
    await globals.app.saveHomeState();
  }
}

class _HomePageState extends State<HomePage> {
  final List<DropdownMenuItem<MaterialColor>> _themeDropdown = [];

  int _counter = 0;
  MaterialColor? _selectedItem = globals.themes['Blue'];
  HomePageData state() => globals.app.homePageStateNotifier.value;

  @override
  void initState() {
    super.initState();
    //init action button
    widget.initFloatingAction(_incrementCounter, const Icon(Icons.add));
    //init this state
    widget.initState(context);

    //build themedropdown
    for (var theme in globals.themes.keys) {
      MaterialColor color = globals.themes[theme]!;
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
    }

    loadState(state());
  }

  void loadState(HomePageData state) {
    //set state
    _selectedItem = globals.themes.values.elementAt(state.theme);
    _counter = state.count;
  }

  void _incrementCounter() {
    _counter++;
    globals.app.homePageStateNotifier.value =
        HomePageData(state().theme, _counter);
  }

  void _themeChanged(MaterialColor? color) {
    _selectedItem = color;
    if (color != null) {
      state().theme = globals.themes.values.toList().indexOf(color);
      widget.themeNotifier.value = color;
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
          body: Center(
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
          actionButton: widget.floatingActionButton,
        );
      },
    );
  }
}
