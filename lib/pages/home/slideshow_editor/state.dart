import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:ut_report_generator/components/export_box/entry.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class SlideshowEditorState {
  final ScrollController scrollController;
  final GlobalKey<ExpandableFabState> fabKey;
  /* this has to be lifted */
  int openSlideMenuIndex;

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
  List<Slide> visibleSlides;
  /* this has to be lifted */
  final GlobalKey<AnimatedListState> visibleSlidesListKey;
  /* this has to be lifted */
  Slideshow? slideshow;
  FutureStatus status;

  SlideshowEditorState({
    required this.scrollController,
    required this.fabKey,
    required this.openSlideMenuIndex,
    required this.portalController,
    required this.portalAnimationController,
    required this.exports,
    required this.exportsListKey,
    required this.visibleSlides,
    required this.visibleSlidesListKey,
    this.slideshow,
    required this.status,
  });
}
