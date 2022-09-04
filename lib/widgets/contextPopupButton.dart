import 'package:flutter/material.dart';

class ContextPopupButton extends PopupMenuButton<String> {
  ContextPopupButton({super.key, super.icon, required super.itemBuilder});

  void Function() showDialog = () {
    print('default context dialog');
  };

  @override
  PopupMenuButtonState<String> createState() => _ContextPopupButtonState();
}

class _ContextPopupButtonState extends PopupMenuButtonState<String> {
  _ContextPopupButtonState();

  @override
  void initState() {
    super.initState();
    print('setting showDialog');
    (widget as ContextPopupButton).showDialog = () {
      print('showing button');
      super.showButtonMenu();
    };
  }

  @override
  Widget build(BuildContext context) {
    (widget as ContextPopupButton).showDialog = () {
      print('showing button');
      super.showButtonMenu();
    };
    return super.build(context);
  }
}
