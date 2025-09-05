import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/api/file_response.dart';
import 'package:ut_report_generator/api/image_slide/edit_image_slide.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/report.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/components/common_appbar.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/error_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/loading_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/widget.dart';
import 'package:ut_report_generator/components/input_component.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/pages/home/report-editor/image_slide_section/widget.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/widget.dart';
import 'package:ut_report_generator/pages/home/report-editor/progress_alert_dialog.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/shimmer_slide.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
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

class _ReportEditorState extends State<ReportEditor> {
  late TextEditingController reportNameController;
  ReportClass? report;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<ReportClass> _loadReport() async {
    return widget.reportCallback().then((report) {
      setState(() {
        this.report = report;
        reportNameController = TextEditingController(text: report.reportName);
      });

      context.read<ScaffoldController>().setFabBuilder(
        (context) => ExpandableFab(
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
            // Botón para añadir Tabla dinámica
            FloatingActionButton.small(
              heroTag: "add_pivot_table",
              onPressed: () {
                _addPivotTable();
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
          title: InputComponent(
            label: "Nombre del reporte",
            hint: "Ingrese el nombre del reporte",
            controller: reportNameController,
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.threed_rotation)),
          ],
          leading: IconButton(
            onPressed: () {
              context.read<ScaffoldController>()
                ..setAppBarBuilder(null)
                ..setFabBuilder(null);
              context.pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
      );

      return report;
    });
  }

  Future<void> _addPivotTable() async {
    pivot_table_api
        .createPivotTable(
          report: report!.identifier,
          dataFiles:
              (report!.slides.firstWhere((slide) => slide is PivotTable)
                      as PivotTable)
                  .source
                  .files,
        )
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 500,
          ), // duración de la transición
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child:
              report != null
                  ? Column(
                    key: ValueKey('content_loaded'),
                    children:
                        report!.slides.indexed.map((data) {
                          final (index, slide) = data;
                          if (slide is PivotTable) {
                            return PivotTableSection(
                              report: report!.identifier,
                              pivotTable: slide,
                              updatePivotTable: (callback) {
                                setState(() {
                                  report!.slides[index] = callback(slide);
                                });
                              },
                            );
                          }
                          if (slide is ImageSlide) {
                            return ImageSlideSection(initialSlide: slide);
                          }
                          return const Text("Tipo de slide inválido");
                        }).toList(),
                  )
                  : const ShimmerSlide(key: ValueKey('shimmer')),
        ),
      ),
    );
  }
}
