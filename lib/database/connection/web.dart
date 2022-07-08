import 'package:drift/web.dart';
import '../database.dart';

SharedDatabase constructDb() {
  return SharedDatabase(WebDatabase('db'));
}
