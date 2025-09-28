import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:ut_report_generator/components/export_box/entry.dart';
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
import 'package:ut_report_generator/pages/home/report_editor/image_slide_section/image_slide_edit_pane.dart';
import 'package:ut_report_generator/pages/home/report_editor/image_slide_section/widget.dart';
import 'package:ut_report_generator/pages/home/report_editor/pivot_table_section/pivot_table_edit_pane.dart';
import 'package:ut_report_generator/pages/home/report_editor/pivot_table_section/pivot_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/report_editor/pivot_table_section/widget.dart';
import 'package:ut_report_generator/pages/home/report_editor/progress_alert_dialog.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/shimmer_slide.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/slide_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/report_editor/slide/tabbed_menu.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';
import 'package:ut_report_generator/api/report/self.dart' as report_api;
import 'package:ut_report_generator/api/pivot_table/self.dart'
    as pivot_table_api;

class ReportEditor extends StatefulWidget {
  final Future<ReportClass> Function() reportCallback;

  ReportEditor({super.key, required this.reportCallback});

  @override
  State<ReportEditor> createState() => _ReportEditorState();
}

class _ReportEditorState extends State<ReportEditor>
    with SingleTickerProviderStateMixin {
  ReportClass? _report;
  final ScrollController _scrollController = ScrollController();
  final fabKey = GlobalKey<ExpandableFabState>();

  int _openSlideMenuIndex = -1;
  final OverlayPortalController _portalController = OverlayPortalController();
  late final AnimationController _portalAnimationController;
  late final Animation _portalOpacityAnimation;
  late final Animation _portalOffsetAnimation;
  final List<ExportBoxEntry> _exports = [];
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();

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
    _loadReport();
  }

  @override
  void dispose() {
    super.dispose();
    _portalAnimationController.dispose();
    _scrollController.dispose();
  }

  List<String> _getRecentFiles() {
    var pivotTables = _report!.slides.whereType<PivotTable>().toList();
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

  Future<ReportClass> _loadReport() async {
    return widget.reportCallback().then((report) {
      setState(() {
        this._report = report;
      });

      context.read<ScaffoldController>().setFabBuilder(
        (context) => ExpandableFab(
          key: fabKey,
          openButtonBuilder: RotateFloatingActionButtonBuilder(
            fabSize: ExpandableFabSize.regular,
            child: const Text(
              "Añadir",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
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
                        _addPivotTable(files);
                      },
                    );
                  },
                );
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
        ),
      );

      context.read<ScaffoldController>().setAppBarBuilder(
        commonAppbar(
          actions: [
            PopupMenuButton(
              icon: const Icon(
                Icons.import_export_outlined,
                color: Colors.white,
              ),
              tooltip: "Exportar reporte",
              onSelected: (_) {
                _compileReport();
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
            onPressed: () {
              context.read<ScaffoldController>()
                ..setAppBarBuilder(null)
                ..setFabBuilder(null);
              context.pop();
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      );

      return report;
    });
  }

  Future<void> _addPivotTable(List<String> files) async {
    pivot_table_api
        .createPivotTable(report: _report!.identifier, dataFiles: files)
        .then((value) {
          setState(() {
            _report = _report!.copyWith(
              slides: copyWithAdded(_report!.slides, value),
            );
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }
          });
        });
  }

  void _compileReport() {
    setState(() {
      final identifier = DateTime.now().toIso8601String();
      _exports.add(
        ExportBoxEntry(
          identifier: identifier,
          process: Future.delayed(Duration(seconds: 2), () {
            return report_api.compileReport(report: _report!.identifier);
          }),
        ),
      );
    });
  }

  Widget _optionComponent<ResponseType extends FileResponse>({
    required void Function() close,
    required Future<ResponseType> Function() callback,
    required String label,
    required IconData icon,
    required String alertTitle,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        close();
        showDialog(
          context: context,
          builder: (context) {
            return ProgressAlertDialog(callback: callback, title: alertTitle);
          },
        );
      },
      label: Text(label),
      icon: Icon(icon),
    );
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
    final reportBloc = ReportBloc(
      initialReport: _report!,
      setReport: (callback) {
        setState(() {
          _report = callback(_report!);
        });
      },
    );

    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) {
        if (_openSlideMenuIndex == -1 || _report == null)
          return const SizedBox();

        final slide = _report!.slides[_openSlideMenuIndex];

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
                    report: _report!.identifier,
                    initialSlide: slide,
                    setSlide: (callback) {
                      setState(() {
                        _report!.slides[_openSlideMenuIndex] = callback(
                          _report!.slides[_openSlideMenuIndex] as PivotTable,
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
                    report: _report!.identifier,
                    initialSlide: slide,
                    setSlide: (callback) {
                      setState(() {
                        _report!.slides[_openSlideMenuIndex] = callback(
                          _report!.slides[_openSlideMenuIndex] as ImageSlide,
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
      child: _buildReportContent(reportBloc),
    );
  }

  Widget _buildReportContent(ReportBloc bloc) {
    if (_report == null) return const ShimmerSlide();

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              SlideshowHeader(report: _report!, bloc: bloc),
              ..._report!.slides.indexed.map((data) {
                final (index, slide) = data;
                if (slide is PivotTable) {
                  return SlideFrame(
                    isMenuOpen: _openSlideMenuIndex == index,
                    openMenu: () => _openSlideMenu(index),
                    child: PivotTableSection(
                      report: _report!.identifier,
                      pivotTable: slide,
                      updatePivotTable: (callback) {
                        setState(() {
                          _report!.slides[index] = callback(slide);
                        });
                      },
                    ),
                  );
                }
                if (slide is ImageSlide) {
                  return SlideFrame(
                    isMenuOpen: _openSlideMenuIndex == index,
                    openMenu: () => _openSlideMenu(index),
                    child: ImageSlideSection(initialSlide: slide),
                  );
                }
                return const Text("Tipo de slide inválido");
              }),
            ],
          ),
        ),
        Positioned(
          top: 16,
          bottom: 16,
          left: 16,
          width: 64,
          child: AnimatedList(
            key: _animatedListKey,
            shrinkWrap: true,
            itemBuilder: (context, index, animation) {
              final entry = _exports[index];
              return ExportBox(
                key: ValueKey(entry.identifier),
                entry: entry,
                retry: () {},
                remove: () {
                  setState(() {
                    _exports.removeWhere(
                      (innerEntry) => innerEntry.identifier == entry.identifier,
                    );
                  });
                },
              );
              // return AnimatedBuilder(
              //   animation: animation,
              //   builder: (context, widget) {
              //     return Opacity(opacity: animation.value, child: widget);
              //   },
              //   child: ExportBox(
              //     key: ValueKey(entry.identifier),
              //     entry: entry,
              //     retry: () {},
              //     remove: () {
              //       setState(() {
              //         _exports.removeWhere(
              //           (innerEntry) =>
              //               innerEntry.identifier == entry.identifier,
              //         );
              //       });
              //     },
              //   ),
              // );
            },
            initialItemCount: 0,
          ),
        ),
      ],
    );
  }
}
