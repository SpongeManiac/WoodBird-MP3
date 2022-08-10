import 'dart:convert';

import 'package:drift/src/runtime/data_class.dart' show DataClass;

import '../baseState.dart';
import '../../../database/database.dart';

class HomePageData extends BaseDataDB {
  HomePageData(this.theme, this.count, this.color,
      [this.controls = const [0, 1, 2, 3, 4]]);
  int theme;
  int count;
  int color;
  List<int> controls;

  @override
  HomePageData copy() {
    return HomePageData(theme, count, color, controls);
  }

  @override
  HomePageData fromEntry(DataClass dataclass) {
    HomePageStateDB data = dataclass as HomePageStateDB;
    var copy = this.copy();
    copy.theme = data.theme;
    copy.count = data.count;
    copy.color = data.color;
    copy.controls = json.decode(data.controls).cast<int>();
    return copy;
  }

  @override
  HomePageStateDB getEntry() {
    return HomePageStateDB(
        id: 1,
        theme: theme,
        count: count,
        color: color,
        controls: controls.toString());
  }

  @override
  void saveData() {
    db.setHomeState(getEntry());
  }

  @override
  HomePageStateCompanion getCompanion() {
    // return HomePageStateCompanion(
    //     theme: Value(theme), count: Value(count), color: Value(color));
    return getEntry().toCompanion(true);
  }
}
