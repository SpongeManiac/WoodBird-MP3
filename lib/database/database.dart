import 'package:drift/drift.dart';

part 'database.g.dart';

@DataClassName('Song')
class Songs extends Table {
  // PrimaryKey
  IntColumn get id => integer().autoIncrement()();
  //Song data
  TextColumn get artist => text().withLength(min: 4, max: 128)();
  TextColumn get name => text().withLength(min: 4, max: 128)();
  // where the file is stored locally
  TextColumn get localPath => text().withLength(min: 4, max: 512)();
}

@DataClassName('Album')
class Albums extends Table {
  // PrimaryKey
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 4, max: 128)();
  // set default to empty description
  TextColumn get description =>
      text().withLength(min: 0, max: 256).withDefault(const Constant(''))();
}

@DataClassName('AlbumSong')
class AlbumSongs extends Table {
  IntColumn get id => integer().autoIncrement()();
}

@DriftDatabase(tables: [
  Songs,
  Albums,
  AlbumSongs,
])
class SharedDatabase extends _$SharedDatabase {
  // we tell the database where to store the data with this constructor
  SharedDatabase(QueryExecutor e) : super(e);

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;
}
