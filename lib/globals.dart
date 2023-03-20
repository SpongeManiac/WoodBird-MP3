import 'shared/shared.dart';
import 'package:flutter/material.dart';
import 'database/connection/shared.dart';
import 'package:test_project/database/database.dart';
import 'shared/baseApp.dart';

BaseApp? _app;
BaseApp get app => _app ??= getApp();

SharedDatabase? _db;
//reference to db
SharedDatabase get db => _db ??= constructDb();

//themes
Map<String, MaterialColor> themes = {
  'Blue': Colors.blue,
  'Red': Colors.red,
  'Purple': Colors.purple,
  'Teal': Colors.teal,
  'Orange': Colors.orange,
  'Custom': Colors.green,
};
