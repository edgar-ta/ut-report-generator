import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:ut_report_generator/api/file_response.dart';
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
import 'package:ut_report_generator/pages/home/report-editor/image_slide_section/image_slide_edit_pane.dart';
import 'package:ut_report_generator/pages/home/report-editor/image_slide_section/widget.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_table_edit_pane.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/pivot_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/widget.dart';
import 'package:ut_report_generator/pages/home/report-editor/progress_alert_dialog.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/shimmer_slide.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/slide_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/tabbed_menu.dart';
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
  late TextEditingController reportNameController;
  ReportClass? report;
  final ScrollController _scrollController = ScrollController();
  final fabKey = GlobalKey<ExpandableFabState>();

  int openSlideMenuIndex = -1;
  final OverlayPortalController _portalController = OverlayPortalController();
  late final AnimationController _portalAnimationController;
  late final Animation _portalOpacityAnimation;
  late final Animation _portalOffsetAnimation;

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
    var pivotTables = report!.slides.whereType<PivotTable>().toList();
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
        this.report = report;
        reportNameController = TextEditingController(text: report.reportName);
        reportNameController.addListener(() {
          setState(() {
            this.report = this.report!.copyWith(
              reportName: reportNameController.value.text,
            );
          });
        });
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
              onSelected: (_) {},
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
        .createPivotTable(report: report!.identifier, dataFiles: files)
        .then((value) {
          setState(() {
            report = report!.copyWith(
              slides: copyWithAdded(report!.slides, value),
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

  Future<report_api.RenderReport_Response> _renderReport() {
    return report_api.renderReport(identifier: report!.identifier);
  }

  Future<report_api.ExportReport_Response> _exportReport() {
    return report_api.exportReport(identifier: report!.identifier);
  }

  Future<FileResponse> _renderReportAsPdf() {
    return Future.error(
      Exception("El sistema aun no soporta este tipo de archivo"),
    );
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
    if (openSlideMenuIndex == -1) {
      _portalController.show();
      _portalAnimationController.forward();
    }
    setState(() {
      openSlideMenuIndex = index;
    });
  }

  void _closeSlideMenu() {
    _portalAnimationController.reverse();
    _portalController.hide();

    setState(() {
      openSlideMenuIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportBloc = ReportBloc(
      initialReport: report!,
      setReport: (callback) {
        setState(() {
          report = callback(report!);
        });
      },
    );

    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) {
        if (openSlideMenuIndex == -1 || report == null) return const SizedBox();

        final slide = report!.slides[openSlideMenuIndex];

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
                    report: report!.identifier,
                    initialSlide: slide,
                    setSlide: (callback) {
                      setState(() {
                        report!.slides[openSlideMenuIndex] = callback(
                          report!.slides[openSlideMenuIndex] as PivotTable,
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
                    report: report!.identifier,
                    initialSlide: slide,
                    setSlide: (callback) {
                      setState(() {
                        report!.slides[openSlideMenuIndex] = callback(
                          report!.slides[openSlideMenuIndex] as ImageSlide,
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
    if (report == null) return const ShimmerSlide();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Text(
                  "Creado ${report!.creationDate.relativeTimeLocale(Locale("es", "MX"))}",
                ),
                InvisibleTextField(
                  controller: reportNameController,
                  style: TextStyle(fontSize: 36),
                  textAlign: TextAlign.center,
                  onChanged: bloc.renameReport,
                ),
                SegmentedButton(
                  onSelectionChanged: (_) {},
                  segments: [
                    ButtonSegment(
                      value: VisualizationMode.asReport,
                      icon: Icon(Icons.report),
                    ),
                    ButtonSegment(
                      value: VisualizationMode.chartsOnly,
                      icon: Icon(Icons.bar_chart),
                    ),
                  ],
                  selected: {report!.visualizationMode},
                ),
              ],
            ),
          ),
          ...report!.slides.indexed.map((data) {
            final (index, slide) = data;
            if (slide is PivotTable) {
              return SlideFrame(
                isMenuOpen: openSlideMenuIndex == index,
                openMenu: () => _openSlideMenu(index),
                child: PivotTableSection(
                  report: report!.identifier,
                  pivotTable: slide,
                  updatePivotTable: (callback) {
                    setState(() {
                      report!.slides[index] = callback(slide);
                    });
                  },
                ),
              );
            }
            if (slide is ImageSlide) {
              return SlideFrame(
                isMenuOpen: openSlideMenuIndex == index,
                openMenu: () => _openSlideMenu(index),
                child: ImageSlideSection(initialSlide: slide),
              );
            }
            return const Text("Tipo de slide inválido");
          }),
        ],
      ),
    );
  }
}
