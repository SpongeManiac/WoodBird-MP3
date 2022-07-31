import 'package:flutter/material.dart';
import 'package:test_project/screens/themedPage.dart';

enum ViewState {
  create,
  read,
  update,
  delete,
}

abstract class CRUDPage extends ThemedPage {
  CRUDPage({super.key, required super.title});

  ValueNotifier<ViewState> stateNotifier =
      ValueNotifier<ViewState>(ViewState.read);
  ViewState get state => stateNotifier.value;
  set state(state) => stateNotifier.value = state;

  //crud ops
  Widget create(BuildContext context);
  Widget read(BuildContext context);
  Widget update(BuildContext context);
  Widget delete(BuildContext context);
}
