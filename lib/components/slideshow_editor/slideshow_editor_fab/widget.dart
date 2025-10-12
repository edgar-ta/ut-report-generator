import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class SlideshowEditorFab extends StatefulWidget {
  SlideshowEditorFab({super.key});

  @override
  State<SlideshowEditorFab> createState() => _SlideshowEditorFabState();
}

class _SlideshowEditorFabState extends State<SlideshowEditorFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: () {}, child: Icon(Icons.add));
  }
}
