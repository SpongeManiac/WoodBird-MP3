import 'package:drift/src/runtime/data_class.dart';

import '../baseState.dart';
import '../../../database/database.dart';

class HomePageData extends BaseDataDB {
  HomePageData(this.theme, this.count);
  int theme;
  int count;

  @override
  HomePageData copy() {
    return HomePageData(theme, count);
  }

  @override
  HomePageData fromEntry(DataClass dataclass) {
    HomePageStateDB data = dataclass as HomePageStateDB;
    var copy = this;
    copy.theme = data.theme;
    copy.count = data.count;
    return copy;
  }

  @override
  HomePageStateDB getEntry() {
    return HomePageStateDB(id: 1, theme: theme, count: count);
  }

  @override
  void saveData() {
    db.setHomeState(getEntry());
  }

  @override
  HomePageStateCompanion getCompanion() {
    return HomePageStateCompanion(theme: Value(theme), count: Value(count));
  }
}
