import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../database.dart';
import '../../globals.dart' as globals;

SharedDatabase constructDb() {
  final db = LazyDatabase(() async {
    final file = File(await globals.dbPath());
    return NativeDatabase(file);
  });
  return SharedDatabase(db);
}
