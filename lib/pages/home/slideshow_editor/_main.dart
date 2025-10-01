import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:ut_report_generator/components/empty_slideshow_placeholder.dart';
import 'package:ut_report_generator/components/export_box/entry.dart';
import 'package:ut_report_generator/components/slideshow_editor_menu.dart';
import 'package:ut_report_generator/components/slideshow_header.dart';
import 'package:ut_report_generator/models/response/file_response.dart';
import 'package:ut_report_generator/api/image_slide/edit_image_slide.dart';
import 'package:ut_report_generator/blocs/image_slide_bloc.dart';
import 'package:ut_report_generator/blocs/pivot_table_bloc.dart';
import 'package:ut_report_generator/blocs/report_bloc.dart';
import 'package:ut_report_generator/components/file_selector/widget.dart';
import 'package:ut_report_generator/components/invisible_text_field.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/components/common_appbar.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/error_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/loading_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/widget.dart';
import 'package:ut_report_generator/components/input_component.dart';
import 'package:ut_report_generator/models/report/visualization_mode.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/components/export_box/widget.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/image_slide_section/image_slide_edit_pane.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/image_slide_section/widget.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/pivot_table_section/widget.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/pivot_table_section/pivot_table_edit_pane.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/pivot_table_section/pivot_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/progress_alert_dialog.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/shimmer_slide.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/slide_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/tabbed_menu.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/state.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/future_status.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';
import 'package:ut_report_generator/api/report/self.dart' as report_api;
import 'package:ut_report_generator/api/pivot_table/self.dart'
    as pivot_table_api;

class SlideshowEditor extends StatefulWidget {
  final Future<Slideshow> Function() slideshowCallback;
  final Future<void> Function() callbackWhenReturning;

  SlideshowEditor({
    super.key,
    required this.slideshowCallback,
    required this.callbackWhenReturning,
  });

  @override
  State<SlideshowEditor> createState() => _SlideshowEditorState();
}

class _SlideshowEditorState extends State<SlideshowEditor>
    with SingleTickerProviderStateMixin {
  late SlideshowEditorState state;

  @override
  void initState() {
    super.initState();
    state = SlideshowEditorState(
      scrollController: ScrollController(),
      fabKey: GlobalKey<ExpandableFabState>(),
      openSlideMenuIndex: -1,
      portalController: OverlayPortalController(),
      portalAnimationController: AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      ),
      exports: [],
      exportsListKey: GlobalKey<AnimatedListState>(),
      visibleSlides: [],
      visibleSlidesListKey: GlobalKey<AnimatedListState>(),
      slideshow: null,
      status: FutureStatus.pending,
    );

    _loadReport();
  }

  @override
  void dispose() {
    super.dispose();
    state.portalAnimationController.dispose();
    state.scrollController.dispose();
  }

  List<String> _getRecentFiles() {
    var pivotTables = state.slideshow!.slides.whereType<PivotTable>().toList();
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
    state.fabKey.currentState?.close();
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
              controller: state.scrollController,
            );
          },
        );
      },
    );
  }

  Future<void> _loadReport() async {
    return widget
        .slideshowCallback()
        .then((report) {
          setState(() {
            state.status = FutureStatus.success;
            state.slideshow = report;
            state.visibleSlides =
                state.slideshow!.slides.where((slide) {
                  if (state.slideshow!.visualizationMode ==
                      VisualizationMode.asReport) {
                    return true;
                  }
                  return slide is PivotTable;
                }).toList();
          });
          context.read<ScaffoldController>()
            ..setFabBuilder(_slideshowEditorFab)
            ..setAppBarBuilder(_slideshowEditorAppBar);
        })
        .catchError((_) {
          setState(() {
            state.status = FutureStatus.error;
          });
        });
  }

  void _compileReport() {
    setState(() {
      final identifier = DateTime.now().toIso8601String();
      state.exportsListKey.currentState!.insertItem(0);
      state.exports.add(
        ExportBoxEntry(
          identifier: identifier,
          process: Future.delayed(Duration(seconds: 2), () {
            return report_api.compileReport(
              report: state.slideshow!.identifier,
            );
          }),
          setState: (callback) {
            setState(() {
              final index = state.exports.indexWhere(
                (export) => export.identifier == identifier,
              );
              state.exports[index] = callback();
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
      state.exportsListKey.currentState!.insertItem(state.exports.length);
      state.exports.add(
        ExportBoxEntry(
          identifier: identifier,
          process: Future.delayed(Duration(seconds: 2), () {
            return report_api.exportReport(report: state.slideshow!.identifier);
          }),
          setState: (callback) {
            setState(() {
              final index = state.exports.indexWhere(
                (export) => export.identifier == identifier,
              );
              state.exports[index] = callback();
            });
          },
          status: FutureStatus.pending,
        ),
      );
    });
  }

  void _openSlideMenu(int index) {
    if (state.openSlideMenuIndex == -1) {
      state.portalController.show();
      state.portalAnimationController.forward();
    }
    setState(() {
      state.openSlideMenuIndex = index;
    });
  }

  void _closeSlideMenu() {
    state.portalAnimationController.reverse();
    state.portalController.hide();

    setState(() {
      state.openSlideMenuIndex = -1;
    });
  }

  Widget _slideshowEditorFab(BuildContext context) {
    return ExpandableFab(
      key: state.fabKey,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        fabSize: ExpandableFabSize.regular,
        child: const Text(
          "Añadir",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
      ),
      type: ExpandableFabType.up,
      distance: 80, // distancia de los botones hijos al FAB principal
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.2), // fondo semitransparente
      ),
      childrenAnimation: ExpandableFabAnimation.none,
      children: [
        FloatingActionButton.small(
          heroTag: "add_pivot_table",
          onPressed: () {
            final bloc = SlideshowEditorBloc(
              initialReport: state.slideshow!,
              setReport: (callback) {
                state.slideshow = callback(state.slideshow!);
              },
            );
            _addPivotTableDialog(bloc);
          },
          tooltip: "Tabla dinámica",
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.bar_chart),
              SizedBox(height: 2),
              Text("Tabla", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),

        // Botón para añadir Imagen
        FloatingActionButton.small(
          heroTag: "add_image",
          onPressed: () async {
            //
          },
          tooltip: "Imagen",
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image),
              SizedBox(height: 2),
              Text("Imagen", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _slideshowEditorAppBar(BuildContext context) {
    return CommonAppbar(
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.import_export_outlined, color: Colors.white),
          tooltip: "Exportar reporte",
          onSelected: (value) {
            if (value == "pdf") {
              _compileReport();
            }
            if (value == "zip") {
              _exportReport();
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: "pdf",
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text('Exportar PDF'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "zip",
                  child: ListTile(
                    leading: Icon(Icons.archive),
                    title: Text('Exportar ZIP'),
                  ),
                ),
              ],
        ),
      ],
      leading: IconButton(
        onPressed: () async {
          context.read<ScaffoldController>()
            ..setAppBarBuilder(null)
            ..setFabBuilder(null);
          context.pop();
          await widget.callbackWhenReturning();
        },
        icon: Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.status == FutureStatus.error) {
      return _errorState();
    }

    if (state.status == FutureStatus.pending) {
      return _loadingState();
    }

    if (state.status == FutureStatus.success && state.slideshow != null) {
      return _successState();
    }

    return Placeholder(child: Text("Invalid future state"));
  }

  Widget _errorState() {
    return Text("Algo salió mal");
  }

  Widget _loadingState() {
    return ShimmerSlide();
  }

  Widget _successState() {
    final reportBloc = SlideshowEditorBloc(
      initialReport: state.slideshow!,
      setReport: (callback) {
        setState(() {
          state.slideshow = callback(state.slideshow!);
        });
      },
    );

    return SlideshowEditorMenu(
      portalController: state.portalController,
      animationController: state.portalAnimationController,
      imageSlideBlocBuilder:
          (imageSlide) => ImageSlideBloc(
            report: report,
            initialSlide: initialSlide,
            setSlide: setSlide,
          ),
      pivotTableBlocBuilder:
          (pivotTable) => PivotTableBloc(
            report: report,
            initialSlide: initialSlide,
            setSlide: setSlide,
          ),
      closeSlideMenu: _closeSlideMenu,
      child: _buildReportContent(reportBloc),
    );
  }

  Widget _buildReportContent(SlideshowEditorBloc bloc) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: state.scrollController,
          child: Column(
            children: [
              SlideshowHeader(report: state.slideshow!, bloc: bloc),
              if (state.visibleSlides.isEmpty)
                EmptySlideshowPlaceholder(
                  onCreatePressed: () {
                    _addPivotTableDialog(bloc);
                  },
                ),
              if (state.visibleSlides.isNotEmpty)
                AnimatedList(
                  shrinkWrap: true,
                  itemBuilder: (context, index, animation) {
                    final slide = state.visibleSlides[index];
                    if (slide is PivotTable) {
                      return SlideFrame(
                        isMenuOpen: state.openSlideMenuIndex == index,
                        openMenu: () => _openSlideMenu(index),
                        child: PivotTableSection(
                          data: slide.data,
                          chartName: slide.title,
                        ),
                      );
                    }
                    if (slide is ImageSlide) {
                      return SlideFrame(
                        isMenuOpen: state.openSlideMenuIndex == index,
                        openMenu: () => _openSlideMenu(index),
                        child: ImageSlideSection(initialSlide: slide),
                      );
                    }
                    return Placeholder(child: Text("Tipo de slide inválido"));
                  },
                  initialItemCount: state.visibleSlides.length,
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
            key: state.exportsListKey,
            itemBuilder: (context, index, animation) {
              final entry = state.exports[index];
              return ExportBox(
                timeout: Duration(seconds: 3),
                interactionTimeout: Duration(seconds: 1),
                key: ValueKey(entry.identifier),
                entry: entry,
                retry: () {},
                remove: () {
                  setState(() {
                    final innerIndex = state.exports.indexWhere(
                      (innerEntry) => innerEntry.identifier == entry.identifier,
                    );
                    state.exportsListKey.currentState!.removeItem(innerIndex, (
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
                    state.exports.removeAt(innerIndex);
                  });
                },
              );
            },
            initialItemCount: state.exports.length,
          ),
        ),
      ],
    );
  }
}
