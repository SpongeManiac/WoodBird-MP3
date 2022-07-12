import 'package:flutter/material.dart';

import 'themedPage.dart';

class SongsPage extends ThemedPage {
  SongsPage({
    Key? key,
    required super.title,
  }) : super(key: key);

  @override
  State<SongsPage> createState() => _SongsPageState();

  @override
  Future<void> saveState() {
    // TODO: implement saveState
    throw UnimplementedError();
  }
}

class _SongsPageState extends State<SongsPage> {
  @override
  void initState() {
    super.initState();
    widget.initState(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Song Page'));
  }
}
