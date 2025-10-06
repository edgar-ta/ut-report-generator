import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box/entry.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class SlideshowEditorState {
  final ScrollController scrollController;
  /* this has to be lifted */
  final Slide? openSlide;

  // this has to be lifted
  /* this has to be lifted */
  final List<ExportBoxEntry> exports;
  /* this has to be lifted */
  final GlobalKey<AnimatedListState> exportsListKey;
  /* this has to be lifted */
  final List<Slide> visibleSlides;
  /* this has to be lifted */
  final GlobalKey<AnimatedListState> visibleSlidesListKey;
  /* this has to be lifted */
  final Slideshow? slideshow;
  final FutureStatus status;

  SlideshowEditorState({
    required this.scrollController,
    required this.openSlide,
    required this.exports,
    required this.exportsListKey,
    required this.visibleSlides,
    required this.visibleSlidesListKey,
    required this.slideshow,
    required this.status,
  });

  SlideshowEditorState copyWith({
    ScrollController? scrollController,
    GlobalKey<ExpandableFabState>? fabKey,
    required Slide? openSlide,
    List<ExportBoxEntry>? exports,
    List<Slide>? visibleSlides,
    required Slideshow? slideshow,
    FutureStatus? status,
  }) {
    return SlideshowEditorState(
      scrollController: scrollController ?? this.scrollController,
      openSlide: openSlide,
      exports: exports ?? this.exports,
      exportsListKey: exportsListKey,
      visibleSlides: visibleSlides ?? this.visibleSlides,
      visibleSlidesListKey: visibleSlidesListKey,
      slideshow: slideshow ?? this.slideshow,
      status: status ?? this.status,
    );
  }
}
