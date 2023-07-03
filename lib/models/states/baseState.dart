import 'package:drift/drift.dart';
import 'package:woodbirdmp3/database/database.dart';
import '../../globals.dart' as globals;

abstract class BaseData extends Object {
  BaseData copy();
}

abstract class BaseDataDB extends BaseData {
  SharedDatabase get db => globals.db;
  void saveData();
  BaseData fromEntry(DataClass dataclass);
  DataClass getEntry();
  UpdateCompanion getCompanion();
}
