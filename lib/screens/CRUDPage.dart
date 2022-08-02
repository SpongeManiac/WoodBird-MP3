import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:test_project/screens/themedPage.dart';

enum ViewState {
  create,
  read,
  update,
  delete,
}

abstract class CRUDPage<T> extends ThemedPage {
  CRUDPage({super.key, required super.title});

  ValueNotifier<ViewState> stateNotifier =
      ValueNotifier<ViewState>(ViewState.read);
  ViewState get state => stateNotifier.value;
  set state(state) => stateNotifier.value = state;

  //state switching
  Future<void> setState(ViewState state, T? item) async {
    if ((state == ViewState.update || state == ViewState.delete)) {}

    switch (state) {
      case ViewState.create:
        await setCreate();
        break;
      case ViewState.read:
        await setRead();
        break;
      case ViewState.update:
        if (item == null) {
          print('gave null item, cancelling update');
        } else {
          await setUpdate(item);
        }
        break;
      case ViewState.delete:
        if (item == null) {
          print('gave null item, cancelling delete');
        } else {
          await setDelete(item);
        }
        break;
    }
  }

  Future<void> setCreate();
  Future<void> setRead();
  Future<void> setUpdate(T item);
  Future<void> setDelete(T item);
  Future<void> cancel();

  //crud views
  Widget createView(BuildContext context);
  Widget readView(BuildContext context);
  Widget updateView(BuildContext context);
  Widget deleteView(BuildContext context);

  //crud functions
  Future<T> create();
  //Future<void> read();
  Future<void> update(T item);
  Future<void> delete(T item);
}
