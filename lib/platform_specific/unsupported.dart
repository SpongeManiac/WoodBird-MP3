import 'package:flutter/cupertino.dart';
import '../shared/baseApp.dart';

BaseApp getApp() {
  return UnsupportedApp(navTitle: 'UnstableApp');
}

class UnsupportedApp extends BaseApp {
  UnsupportedApp({Key? key, String? navTitle})
      : super(key: key, navTitle: navTitle);

  @override
  State<UnsupportedApp> createState() => _UnsupportedAppState();
}

class _UnsupportedAppState extends State<UnsupportedApp> {
  _UnsupportedAppState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Unsupported Platform',
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
