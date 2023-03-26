import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:test_project/screens/themedPage.dart';

enum ViewState {
  create,
  read,
  update,
  delete,
}

abstract class CRUDState<T> extends State<ThemedPage> {
  //CRUDPage({super.key, required super.title});

  ValueNotifier<ViewState> stateNotifier =
      ValueNotifier<ViewState>(ViewState.read);
  ViewState get state => stateNotifier.value;
  set state(state) => stateNotifier.value = state;

  ValueNotifier<T?> editingNotifier = ValueNotifier(null);
  T? get itemToEdit => editingNotifier.value;
  set itemToEdit(newItem) => editingNotifier.value = newItem;

  //view switching
  Future<void> setViewState(ViewState state, T? item) async {
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

  Future<void> setCreate([Future<bool> Function()? onBackOverride]) async {
    itemToEdit = null;
    state = ViewState.create;
    widget.setAndroidBack(
      context,
      onBackOverride ??
          () async {
            await setRead();
            return false;
          },
      Icons.arrow_back_rounded,
    );
  }

  Future<void> setRead([Future<bool> Function()? onBackOverride]) async {
    itemToEdit = null;
    state = ViewState.read;
    widget.setAndroidBack(
      context,
      onBackOverride ??
          () async {
            widget.app.navigation.goto(context, '/');
            return false;
          },
      Icons.home_rounded,
    );
  }

  Future<void> setUpdate(T item,
      [Future<bool> Function()? onBackOverride]) async {
    itemToEdit = item;
    state = ViewState.update;

    widget.setAndroidBack(
      context,
      onBackOverride ??
          () async {
            await cancel();
            return false;
          },
      Icons.arrow_back_rounded,
    );
  }

  Future<void> setDelete(T item) async {
    itemToEdit = item;
    state = ViewState.delete;
  }

  Future<void> cancel() async {
    await setRead();
  }

  //crud views
  Widget createView(BuildContext context);
  Widget readView(BuildContext context);
  Widget updateView(BuildContext context);
  Widget deleteView(BuildContext context);

  //crud functions
  Future<List<T?>> create();
  //Future<List<T>> createAll();
  //Future<void> read();
  Future<T> update(T item);
  Future<List<T>> updateAll(List<T> items) async {
    List<T> updated = [];
    for (T item in items) {
      updated.add(await update(item));
    }
    return updated;
  }

  Future<void> delete(T item);
  Future<void> deleteAll(List<T> items) async {
    for (T item in items) {
      await delete(item);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ViewState>(
      valueListenable: stateNotifier,
      builder: (context, state, _) {
        print('current state: $state');
        switch (state) {
          case ViewState.create:
            return createView(context);
          case ViewState.read:
            return readView(context);
          case ViewState.update:
            return updateView(context);
          case ViewState.delete:
            return deleteView(context);
          default:
            return Center(child: Text('Invalid State'));
        }
      },
    );
  }
}
