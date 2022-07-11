import 'package:drift/web.dart';
import '../database.dart';

SharedDatabase constructDb() {
  print('webdart');
  return SharedDatabase(WebDatabase('db'));
}
