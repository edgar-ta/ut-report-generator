import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box/entry.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class SlideshowEditorState {
  final ScrollController scrollController;
  final String? openSlideIdentifier;

  final List<ExportBoxEntry> exports;
  final GlobalKey<AnimatedListState> exportsListKey;
  final GlobalKey<AnimatedListState> visibleSlidesListKey;
  final Slideshow? slideshow;
  final FutureStatus status;

  SlideshowEditorState({
    required this.scrollController,
    required this.openSlideIdentifier,
    required this.exports,
    required this.exportsListKey,
    required this.visibleSlidesListKey,
    required this.slideshow,
    required this.status,
  });

  SlideshowEditorState copyWith({
    ScrollController? scrollController,
    GlobalKey<ExpandableFabState>? fabKey,
    required String? openSlideIdentifier,
    List<ExportBoxEntry>? exports,
    required Slideshow? slideshow,
    FutureStatus? status,
  }) {
    return SlideshowEditorState(
      scrollController: scrollController ?? this.scrollController,
      openSlideIdentifier: openSlideIdentifier,
      exports: exports ?? this.exports,
      exportsListKey: exportsListKey,
      visibleSlidesListKey: visibleSlidesListKey,
      slideshow: slideshow,
      status: status ?? this.status,
    );
  }
}
