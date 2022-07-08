import 'package:flutter/material.dart';

import 'themedPage.dart';

class SongsPage extends ThemedPage {
  const SongsPage({
    Key? key,
    required super.title,
    required super.themeNotifier,
  }) : super(key: key);

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.getScaffold(
      const Text('Song Page'),
    );
  }
}
