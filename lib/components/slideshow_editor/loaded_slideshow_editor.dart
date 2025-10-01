import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:ut_report_generator/components/empty_slideshow_placeholder.dart';
import 'package:ut_report_generator/components/export_box/entry.dart';
import 'package:ut_report_generator/components/slideshow_header.dart';
import 'package:ut_report_generator/blocs/image_slide_bloc.dart';
import 'package:ut_report_generator/blocs/pivot_table_bloc.dart';
import 'package:ut_report_generator/blocs/report_bloc.dart';
import 'package:ut_report_generator/components/file_selector/widget.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/report/visualization_mode.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/components/export_box/widget.dart';
import 'package:ut_report_generator/pages/home/report_editor/image_slide_section/image_slide_edit_pane.dart';
import 'package:ut_report_generator/pages/home/report_editor/image_slide_section/widget.dart';
import 'package:ut_report_generator/pages/home/report_editor/pivot_table_section/widget.dart';
import 'package:ut_report_generator/pages/home/report_editor/pivot_table_section/pivot_table_edit_pane.dart';
import 'package:ut_report_generator/pages/home/report_editor/pivot_table_section/pivot_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/slide_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/tabbed_menu.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/api/report/self.dart' as report_api;
import 'package:ut_report_generator/utils/future_status.dart';

class LoadedSlideshowEditor extends StatefulWidget {
  Slideshow initialSlideshow;
  LoadedSlideshowEditor({super.key, required this.initialSlideshow});

  @override
  State<LoadedSlideshowEditor> createState() => _LoadedSlideshowEditorState();
}

class _LoadedSlideshowEditorState extends State<LoadedSlideshowEditor>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final fabKey = GlobalKey<ExpandableFabState>();

  int _openSlideMenuIndex = -1;
  final OverlayPortalController _portalController = OverlayPortalController();
  late final AnimationController _portalAnimationController;
  late final Animation _portalOpacityAnimation;
  late final Animation _portalOffsetAnimation;

  final List<ExportBoxEntry> _exports = [];
  final GlobalKey<AnimatedListState> _exportsListKey = GlobalKey();

  late final List<Slide> _visibleSlides;
  final GlobalKey<AnimatedListState> _visibleSlidesListKey = GlobalKey();

  late Slideshow _slideshow;

  @override
  void initState() {
    super.initState();
    _portalAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _portalOpacityAnimation = Tween(begin: 0.toDouble(), end: 0.5).animate(
      CurvedAnimation(
        parent: _portalAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _portalOffsetAnimation = Tween(
      begin: -MENU_WIDTH,
      end: 0.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _portalAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideshow = widget.initialSlideshow;
    _visibleSlides =
        _slideshow.slides.where((slide) {
          if (_slideshow.visualizationMode == VisualizationMode.chartsOnly) {
            return slide is PivotTable;
          }
          return true;
        }).toList();
  }

  @override
  void dispose() {
    super.dispose();
    _portalAnimationController.dispose();
    _scrollController.dispose();
  }

  List<String> _getRecentFiles() {
    var pivotTables =
        widget.initialSlideshow.slides.whereType<PivotTable>().toList();
    pivotTables.sort(
      (first, second) => first.creationDate.compareTo(second.creationDate),
    );
    var uniqueFiles =
        pivotTables
            .map((pivotTable) => pivotTable.source.files)
            .expand((files) => files)
            .toSet()
            .toList();
    return uniqueFiles;
  }

  void _addPivotTableDialog(SlideshowEditorBloc bloc) {
    fabKey.currentState?.close();
    showDialog(
      context: context,
      builder: (context) {
        var recentFiles = _getRecentFiles();

        return FileSelector(
          initialFiles: recentFiles,
          defaultSelection: [],
          legend: null,
          onFilesSelected: (List<String> files) async {
            await bloc.addPivotTable(
              files: files,
              controller: _scrollController,
            );
          },
        );
      },
    );
  }

  void _compileReport() {
    setState(() {
      final identifier = DateTime.now().toIso8601String();
      _exportsListKey.currentState!.insertItem(0);
      _exports.add(
        ExportBoxEntry(
          identifier: identifier,
          process: Future.delayed(Duration(seconds: 2), () {
            return report_api.compileReport(
              report: widget.initialSlideshow.identifier,
            );
          }),
          setState: (callback) {
            setState(() {
              final index = _exports.indexWhere(
                (export) => export.identifier == identifier,
              );
              _exports[index] = callback();
            });
          },
          status: FutureStatus.pending,
        ),
      );
    });
  }

  void _exportReport() {
    setState(() {
      final identifier = DateTime.now().toIso8601String();
      _exportsListKey.currentState!.insertItem(_exports.length);
      _exports.add(
        ExportBoxEntry(
          identifier: identifier,
          process: Future.delayed(Duration(seconds: 2), () {
            return report_api.exportReport(
              report: widget.initialSlideshow.identifier,
            );
          }),
          setState: (callback) {
            setState(() {
              final index = _exports.indexWhere(
                (export) => export.identifier == identifier,
              );
              _exports[index] = callback();
            });
          },
          status: FutureStatus.pending,
        ),
      );
    });
  }

  void _openSlideMenu(int index) {
    if (_openSlideMenuIndex == -1) {
      _portalController.show();
      _portalAnimationController.forward();
    }
    setState(() {
      _openSlideMenuIndex = index;
    });
  }

  void _closeSlideMenu() {
    _portalAnimationController.reverse();
    _portalController.hide();

    setState(() {
      _openSlideMenuIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportBloc = SlideshowEditorBloc(
      initialReport: widget.initialSlideshow,
      setReport: (callback) {
        setState(() {
          _slideshow = callback(_slideshow);
        });
      },
    );

    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) {
        if (_openSlideMenuIndex == -1) return const SizedBox();

        final slide = widget.initialSlideshow.slides[_openSlideMenuIndex];

        return AnimatedBuilder(
          animation: _portalAnimationController,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeSlideMenu,
                    child: Opacity(
                      opacity: _portalOpacityAnimation.value,
                      child: Container(color: Colors.black54),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  width: MENU_WIDTH,
                  right: _portalOffsetAnimation.value,
                  child: child ?? SizedBox.shrink(),
                ),
              ],
            );
          },
          child: Material(
            elevation: 8,
            child: Builder(
              builder: (context) {
                if (slide is PivotTable) {
                  final bloc = PivotTableBloc(
                    report: widget.initialSlideshow.identifier,
                    initialSlide: slide,
                    setSlide: (callback) {
                      setState(() {
                        widget
                            .initialSlideshow
                            .slides[_openSlideMenuIndex] = callback(
                          widget.initialSlideshow.slides[_openSlideMenuIndex]
                              as PivotTable,
                        );
                      });
                    },
                  );
                  return TabbedMenu(
                    editTabBuilder:
                        (_) => PivotTableEditPane(
                          title: slide.title,
                          bloc: bloc,
                          filters: slide.filters,
                        ),
                    metadataTabBuilder:
                        (_) => PivotMetadataPane(
                          files: slide.source.files,
                          bloc: bloc,
                        ),
                  );
                }
                if (slide is ImageSlide) {
                  final bloc = ImageSlideBloc(
                    report: widget.initialSlideshow.identifier,
                    initialSlide: slide,
                    setSlide: (callback) {
                      setState(() {
                        widget
                            .initialSlideshow
                            .slides[_openSlideMenuIndex] = callback(
                          widget.initialSlideshow.slides[_openSlideMenuIndex]
                              as ImageSlide,
                        );
                      });
                    },
                  );
                  return TabbedMenu(
                    editTabBuilder:
                        (_) => ImageSlideEditPane(
                          title: slide.title,
                          parameters: slide.parameters,
                          bloc: bloc,
                        ),
                    metadataTabBuilder:
                        (_) => SlideMetadataPane(
                          identifier: slide.identifier,
                          creationDate: slide.creationDate,
                          preview: slide.preview,
                          category: slide.category,
                        ),
                  );
                }
                return const Text("Tipo de slide inválido");
              },
            ),
          ),
        );
      },
      child: _buildContent(reportBloc),
    );
  }

  Widget _buildContent(SlideshowEditorBloc bloc) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              SlideshowHeader(report: widget.initialSlideshow, bloc: bloc),
              if (_visibleSlides.isEmpty)
                EmptySlideshowPlaceholder(
                  onCreatePressed: () {
                    _addPivotTableDialog(bloc);
                  },
                ),
              if (_visibleSlides.isNotEmpty)
                AnimatedList(
                  key: _visibleSlidesListKey,
                  shrinkWrap: true,
                  itemBuilder: (context, index, animation) {
                    final slide = _visibleSlides[index];
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Opacity(opacity: animation.value, child: child);
                      },
                      child:
                          slide is PivotTable
                              ? (SlideFrame(
                                isMenuOpen: _openSlideMenuIndex == index,
                                openMenu: () => _openSlideMenu(index),
                                child: PivotTableSection(
                                  data: slide.data,
                                  chartName: slide.title,
                                ),
                              ))
                              : (SlideFrame(
                                isMenuOpen: _openSlideMenuIndex == index,
                                openMenu: () => _openSlideMenu(index),
                                child: ImageSlideSection(
                                  initialSlide: slide as ImageSlide,
                                ),
                              )),
                    );
                  },
                  initialItemCount: _visibleSlides.length,
                ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          bottom: 16,
          width: EXPORT_BOX_WIDTH,
          left: 16,
          child: AnimatedList(
            key: _exportsListKey,
            itemBuilder: (context, index, animation) {
              final entry = _exports[index];
              return ExportBox(
                timeout: Duration(seconds: 3),
                interactionTimeout: Duration(seconds: 1),
                key: ValueKey(entry.identifier),
                entry: entry,
                retry: () {},
                remove: () {
                  setState(() {
                    final innerIndex = _exports.indexWhere(
                      (innerEntry) => innerEntry.identifier == entry.identifier,
                    );
                    _exportsListKey.currentState!.removeItem(innerIndex, (
                      context,
                      animation,
                    ) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: animation.value,
                            child: child,
                          );
                        },
                        child: ExportBox(entry: entry),
                      );
                    });
                    _exports.removeAt(innerIndex);
                  });
                },
              );
            },
            initialItemCount: _exports.length,
          ),
        ),
      ],
    );
  }
}
