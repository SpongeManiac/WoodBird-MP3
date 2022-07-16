import 'package:drift/src/runtime/data_class.dart';
import 'package:flutter/material.dart';

import '../baseState.dart';
import '../../../database/database.dart';

class HomePageData extends BaseDataDB {
  HomePageData(this.theme, this.count);
  int theme;
  int count;

  @override
  void saveData() {
    db.setHomeState(getEntry());
  }

  @override
  HomePageStateDB getEntry() {
    return HomePageStateDB(id: 1, theme: theme, count: count);
  }

  @override
  HomePageData fromEntry(DataClass data) {
    data as HomePageStateDB;
    var copy = this;
    copy.theme = data.theme;
    copy.count = data.count;
    return copy;
  }

  @override
  HomePageData copy() {
    return HomePageData(theme, count);
  }

  // @override
  // void fromEntry(BaseData data) {
  //   var state = data as HomePageStateDB;
  //   theme = state.theme;
  //   count = state.count;
  // }
}
