import 'package:flutter/material.dart';
import 'package:test_project/screens/themedPage.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class HomePage extends ThemedPage {
  const HomePage({
    Key? key,
    required super.title,
    required super.themeNotifier,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  final Map<String, MaterialColor> _themes = {
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Purple': Colors.purple,
    'Teal': Colors.teal,
    'Orange': Colors.orange,
  };

  final List<DropdownMenuItem<MaterialColor>> _themeDropdown = [];
  MaterialColor? _selectedItem = Colors.blue;

  @override
  void initState() {
    super.initState();
    //build themedropdown
    for (var theme in _themes.keys) {
      MaterialColor color = _themes[theme]!;
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
    //set selectedItem to first item
    _selectedItem = _themeDropdown[0].value;
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _themeChanged(MaterialColor? color) {
    _selectedItem = color;
    if (color != null && widget.themeNotifier != null) {
      widget.themeNotifier!.value = color;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return widget.getScaffold(
      Center(
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
                  setState(() {
                    _selectedItem;
                  });
                },
                isExpanded: true,
                buttonWidth: 400,
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
              ),
            ),
          ],
        ),
      ),
      FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
