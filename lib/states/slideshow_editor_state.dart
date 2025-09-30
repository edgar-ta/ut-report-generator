import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:ut_report_generator/components/export_box/entry.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';

class SlideshowEditorState {
  final ScrollController scrollController;
  final GlobalKey<ExpandableFabState> fabKey;
  /* this has to be lifted */
  final int openSlideMenuIndex;

  /* this has to be lifted */
  final OverlayPortalController portalController;
  /* this has to be lifted */
  final AnimationController portalAnimationController;

  /* this can le left out */
  final Animation portalOpacityAnimation;
  /* this can le left out */
  final Animation portalOffsetAnimation;

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
  final Slideshow slideshow;

  SlideshowEditorState({
    required this.scrollController,
    required this.fabKey,
    required this.openSlideMenuIndex,
    required this.portalController,
    required this.portalAnimationController,
    required this.portalOpacityAnimation,
    required this.portalOffsetAnimation,
    required this.exports,
    required this.exportsListKey,
    required this.visibleSlides,
    required this.visibleSlidesListKey,
    required this.slideshow,
  });
}
