import 'package:drift/drift.dart';
import 'package:test_project/database/database.dart';
import '../../globals.dart' as globals;

abstract class BaseData extends Object {
  SharedDatabase get db => globals.db;

  void saveData();
  BaseData fromEntry(DataClass data);
  DataClass getEntry();
}
