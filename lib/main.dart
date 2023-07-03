//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'globals.dart' as globals;

//import 'models/tables/homePageData.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  () async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.rpgrogan.free.woodbirdmp3.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/ic_stat_logo',
    );

    //print('${globals.db}');

    await globals.app.loadPageStates().then((value) async {
      runApp(globals.app);
    });
  }();
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     //creates a new material app when _themeNotifier changes
//     if (kIsWeb) {
//       return const Center(
//           child: Text(
//         'Web',
//         textDirection: TextDirection.ltr,
//       ));
//     }
//     return const Center(
//       child: Text(
//         'Dekstop',
//         textDirection: TextDirection.ltr,
//       ),
//     );
    // return ValueListenableBuilder<MaterialColor>(
    //     //the listener
    //     valueListenable: globals.themeNotifier,
    //     //underscores are used for unused variables. Give variable name for listener value.
    //     builder: (context, themeColor, __) {
    //       return MaterialApp(
    //         title: 'WoodBird MP3',
    //         theme: ThemeData(
    //           // This is the theme of your application.
    //           //
    //           // Try running your application with "flutter run". You'll see the
    //           // application has a blue toolbar. Then, without quitting the app, try
    //           // changing the primarySwatch below to Colors.green and then invoke
    //           // "hot reload" (press "r" in the console where you ran "flutter run",
    //           // or simply save your changes to "hot reload" in a Flutter IDE).
    //           // Notice that the counter didn't reset back to zero; the application
    //           // is not restarted.

    //           //use new themeColor
    //           primarySwatch: themeColor,
    //         ),
    //         home: globals.appScaffold,
    //       );
    //     });
  //}
//}
