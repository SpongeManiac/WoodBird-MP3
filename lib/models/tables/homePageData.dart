import '../../database/database.dart';

class HomePageData {
  HomePageData(this.theme, this.count);
  int theme;
  int count;

  HomePageStateDB getEntry() {
    return HomePageStateDB(id: 1, theme: theme, count: count);
  }
}
