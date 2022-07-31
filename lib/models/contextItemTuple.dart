import 'package:flutter/material.dart';

class ContextItemTuple {
  ContextItemTuple(this.icon, [this.onPress, this.onLongPress]);
  IconData icon;
  Future<void> Function()? onPress;
  Future<void> Function()? onLongPress;
}
