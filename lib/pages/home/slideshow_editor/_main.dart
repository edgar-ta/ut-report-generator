import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/components/slideshow_editor/app_subscaffold.dart';
import 'package:ut_report_generator/components/slideshow_editor/empty_slideshow_placeholder.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box/entry.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box_list.dart';
import 'package:ut_report_generator/components/slideshow_editor/slideshow_editor_fab/widget.dart';
import 'package:ut_report_generator/components/slideshow_editor/slideshow_editor_menu.dart';
import 'package:ut_report_generator/components/slideshow_editor/slideshow_header.dart';
import 'package:ut_report_generator/blocs/image_slide_bloc.dart';
import 'package:ut_report_generator/blocs/pivot_table_bloc.dart';
import 'package:ut_report_generator/blocs/slideshow_editor_bloc.dart';
import 'package:ut_report_generator/components/slideshow_editor/file_selector/widget.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/components/util/common_appbar.dart';
import 'package:ut_report_generator/models/report/visualization_mode.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box/widget.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/shimmer_slide.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/state.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/future_status.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';
import 'package:ut_report_generator/api/report/self.dart' as report_api;

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
      openSlide: null,
      exports: [],
      exportsListKey: GlobalKey<AnimatedListState>(),
      visibleSlides: [],
      visibleSlidesListKey: GlobalKey<AnimatedListState>(),
      slideshow: null,
      status: FutureStatus.pending,
    );

    _loadReport();
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
    return waitAtLeast(Duration(seconds: 1), widget.slideshowCallback())
        .then((report) {
          setState(() {
            state = state.copyWith(
              status: FutureStatus.success,
              slideshow: report,
              visibleSlides:
                  report.slides.where((slide) {
                    if (report.visualizationMode ==
                        VisualizationMode.asReport) {
                      return true;
                    }
                    return slide is PivotTable;
                  }).toList(),
              openSlide: state.openSlide,
            );
          });
          context.read<ScaffoldController>()
            ..setFabBuilder(_slideshowEditorFab)
            ..setAppBarBuilder(_slideshowEditorAppBar);
        })
        .catchError((_) {
          setState(() {
            state = state.copyWith(
              status: FutureStatus.error,
              slideshow: state.slideshow,
              openSlide: state.openSlide,
            );
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

  void _exportSlideshow() {
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

  Widget _slideshowEditorFab(BuildContext context) {
    return SlideshowEditorFab(
      addPivotTable: () async {
        // _addPivotTableDialog(bloc);
      },
      addImageSlide: () async {},
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
              _exportSlideshow();
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
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: state.status == FutureStatus.pending ? 1 : 0,
          duration: Duration(milliseconds: 250),
          child: _loadingState(),
        ),
        AnimatedOpacity(
          opacity:
              state.status == FutureStatus.success ||
                      state.status == FutureStatus.error
                  ? 1
                  : 0,
          duration: Duration(milliseconds: 250),
          child:
              state.status == FutureStatus.pending
                  ? SizedBox.shrink()
                  : (state.status == FutureStatus.success
                      ? _successState()
                      : _errorState()),
        ),
      ],
    );
  }

  Widget _errorState() {
    return Text(key: ValueKey('error'), "Algo salió mal");
  }

  Widget _loadingState() {
    return ShimmerSlide(key: ValueKey('loading'));
  }

  Widget _successState() {
    final slideshowBloc = SlideshowEditorBloc(
      initialState: state,
      setInitialState: (callback) {
        setState(() {
          state = callback(state);
        });
      },
    );

    return AppSubscaffold(
      key: ValueKey('success'),
      isMenuOpen: state.openSlide != null,
      bloc: slideshowBloc,
      menu: _buildEditorMenu(slideshowBloc),
      child: _buildEditorContent(slideshowBloc),
    );
  }

  void _setSlide<T extends Slide>(String identifier, T Function(T) callback) {
    setState(() {
      state = state.copyWith(
        openSlide: state.openSlide,
        slideshow: state.slideshow!.copyWith(
          slides:
              state.slideshow!.slides.map((innerSlide) {
                if (innerSlide.identifier == identifier) {
                  return callback(innerSlide as T);
                }
                return innerSlide;
              }).toList(),
        ),
      );
    });
  }

  Widget _buildEditorMenu(SlideshowEditorBloc reportBloc) {
    return SlideshowEditorMenu(
      slide: state.openSlide,
      imageSlideBlocBuilder:
          (imageSlide) => ImageSlideBloc(
            slideshow: state.slideshow!.identifier,
            initialSlide: imageSlide,
            setSlide: (callback) {
              _setSlide(imageSlide.identifier, callback);
            },
          ),
      pivotTableBlocBuilder:
          (pivotTable) => PivotTableBloc(
            slideshow: state.slideshow!.identifier,
            initialSlide: pivotTable,
            setSlide: (callback) {
              _setSlide(pivotTable.identifier, callback);
            },
          ),
    );
  }

  void _removeExport(ExportBoxEntry entry) {
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
            return Opacity(opacity: animation.value, child: child);
          },
          child: ExportBox(entry: entry),
        );
      });
      state.exports.removeAt(innerIndex);
    });
  }

  void _retryExport(ExportBoxEntry entry) {
    //
  }

  Widget _buildEditorContent(SlideshowEditorBloc bloc) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: state.scrollController,
          child: Column(
            children: [
              SlideshowHeader(slideshow: state.slideshow!, bloc: bloc),
              if (state.visibleSlides.isEmpty)
                EmptySlideshowPlaceholder(
                  onCreatePressed: () {
                    _addPivotTableDialog(bloc);
                  },
                ),
              if (state.visibleSlides.isNotEmpty)
                AnimatedList(
                  key: state.visibleSlidesListKey,
                  shrinkWrap: true,
                  itemBuilder: (context, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, widget) {
                        return Opacity(opacity: animation.value, child: widget);
                      },
                      child: bloc.buildSlideFrame(index),
                    );
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
          child: ExportBoxList(
            exportsListKey: state.exportsListKey,
            exports: state.exports,
            removeExport: _removeExport,
            retryExport: _retryExport,
          ),
        ),
      ],
    );
  }
}
