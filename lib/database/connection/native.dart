import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:woodbirdmp3/platform_specific/device.dart';
import '../database.dart';
import '../../globals.dart' as globals;

SharedDatabase constructDb() {
  final db = LazyDatabase(() async {
    final file = File(await (globals.app as DesktopApp).dbPath());
    return NativeDatabase(file);
  });
  return SharedDatabase(db);
}
