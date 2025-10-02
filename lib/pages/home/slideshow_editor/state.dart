import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:ut_report_generator/components/export_box/entry.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class SlideshowEditorState {
  final ScrollController scrollController;
  /* this has to be lifted */
  final Slide? openSlide;

  /* this has to be lifted */
  final OverlayPortalController portalController;
  /* this has to be lifted */
  final AnimationController portalAnimationController;

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
    required this.portalController,
    required this.portalAnimationController,
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
    Slide? openSlide,
    OverlayPortalController? portalController,
    AnimationController? portalAnimationController,
    List<ExportBoxEntry>? exports,
    GlobalKey<AnimatedListState>? exportsListKey,
    List<Slide>? visibleSlides,
    GlobalKey<AnimatedListState>? visibleSlidesListKey,
    Slideshow? slideshow,
    FutureStatus? status,
  }) {
    return SlideshowEditorState(
      scrollController: scrollController ?? this.scrollController,
      openSlide: openSlide ?? this.openSlide,
      portalController: portalController ?? this.portalController,
      portalAnimationController:
          portalAnimationController ?? this.portalAnimationController,
      exports: exports ?? this.exports,
      exportsListKey: exportsListKey ?? this.exportsListKey,
      visibleSlides: visibleSlides ?? this.visibleSlides,
      visibleSlidesListKey: visibleSlidesListKey ?? this.visibleSlidesListKey,
      slideshow: slideshow ?? this.slideshow,
      status: status ?? this.status,
    );
  }
}
