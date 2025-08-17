import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_clipboard/image_clipboard.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/api/change_slide_data.dart';
import 'package:ut_report_generator/api/edit_slide.dart';
import 'package:ut_report_generator/api/export_report.dart';
import 'package:ut_report_generator/api/file_response.dart';
import 'package:ut_report_generator/api/hello_request.dart';
import 'package:ut_report_generator/api/render_report.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/types/report_class.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/api/types/slide_type.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/error_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/loading_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/widget.dart';
import 'package:ut_report_generator/components/input_component.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/widget.dart';
import 'package:ut_report_generator/home/report-editor/progress_alert_dialog.dart';
import 'package:ut_report_generator/home/report-editor/render_button.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';

Widget buildSlideEditor(
  SlideClass slide,
  Future<void> Function(String slideId, List<File> dataFiles) changeSlideData,
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide,
) {
  switch (slide.type) {
    case SlideType.failureRate:
      return FailureSection(
        slideData: slide,
        editSlide: editSlide,
        changeSlideData: changeSlideData,
      );
    case SlideType.average:
      return Center(child: Text("Tipo de diapositiva no soportado"));
    default:
      return Center(child: Text("Tipo de diapositiva no soportado"));
  }
}

class ReportEditor extends StatefulWidget {
  final Future<ReportClass> Function() reportCallback;

  ReportEditor({super.key, required this.reportCallback});

  @override
  State<ReportEditor> createState() => _ReportEditorState();
}

class _ReportEditorState extends State<ReportEditor> {
  late TextEditingController reportNameController;
  ReportClass? report;

  Future<ReportClass> _loadReport() async {
    return waitAtLeast(Duration(seconds: 2), widget.reportCallback()).then((
      report,
    ) {
      setState(() {
        this.report = report;
        reportNameController = TextEditingController(text: report.reportName);
      });
      context.read<ScaffoldController>().setFab(
        RenderButton(
          distance: 8,
          builder: (close, index) {
            switch (index) {
              case 0:
                return _optionComponent(
                  close: close,
                  callback: _renderReport,
                  label: "PPTX",
                  icon: Icons.slideshow,
                  alertTitle: "Renderizando PPTX",
                );
              case 1:
                return _optionComponent(
                  close: close,
                  callback: _exportReport,
                  label: "Reporte",
                  icon: Icons.edit_document,
                  alertTitle: "Exportando reporte",
                );
              default:
                return _optionComponent(
                  close: close,
                  callback: _renderReportAsPdf,
                  label: "PDF",
                  icon: Icons.picture_as_pdf,
                  alertTitle: "Renderizando PDF",
                );
            }
          },
          count: 3,
          width: 192,
          height: 48,
        ),
      );
      context.read<ScaffoldController>().setAppBarBuilder(
        (innerContext) => AppBar(
          leading: IconButton(
            onPressed: () {
              context.go("/home");
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
      );

      return report;
    });
  }

  void _setSlideData({
    required String slideId,
    String? key,
    List<AssetClass>? assets,
    String? preview,
    Map<String, dynamic>? arguments,
  }) {
    setState(() {
      var slides =
          report!.slides.map((slide) {
            if (slide.id == slideId) {
              return slide.copyWith(
                assets: assets,
                arguments: arguments,
                preview: preview,
                key: key,
              );
            }
            return slide;
          }).toList();
      var newReport = report!.copyWith(slides: slides);
      report = newReport;
    });
  }

  Future<void> _changeSlideData(String slideId, List<File> files) async {
    return changeSlideData(
      dataFiles: files.map((file) => file.absolute.path).toList(),
      reportDirectory: report!.reportDirectory,
      slideId: slideId,
    ).then((value) {
      _setSlideData(
        slideId: slideId,
        assets: value.assets,
        preview: value.preview,
        key: value.key,
      );
    });
  }

  Future<void> _editSlide(String slideId, Map<String, dynamic> arguments) {
    return editSlide(
      reportDirectory: report!.reportDirectory,
      slideId: slideId,
      arguments: arguments,
    ).then((value) {
      _setSlideData(
        slideId: slideId,
        assets: value.assets,
        preview: value.preview,
        arguments: arguments,
        key: value.key,
      );
    });
  }

  Future<RenderReport_Response> _renderReport() {
    return renderReport(reportDirectory: report!.reportDirectory);
  }

  Future<ExportReport_Response> _exportReport() {
    return exportReport(reportDirectory: report!.reportDirectory);
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
    // floatingActionButton:
    //     report != null
    //         ? (RenderButton(
    //           distance: 8,
    //           builder: (close, index) {
    //             switch (index) {
    //               case 0:
    //                 return _optionComponent(
    //                   close: close,
    //                   callback: _renderReport,
    //                   label: "PPTX",
    //                   icon: Icons.slideshow,
    //                   alertTitle: "Renderizando PPTX",
    //                 );
    //               case 1:
    //                 return _optionComponent(
    //                   close: close,
    //                   callback: _exportReport,
    //                   label: "Reporte",
    //                   icon: Icons.edit_document,
    //                   alertTitle: "Exportando reporte",
    //                 );
    //               default:
    //                 return _optionComponent(
    //                   close: close,
    //                   callback: _renderReportAsPdf,
    //                   label: "PDF",
    //                   icon: Icons.picture_as_pdf,
    //                   alertTitle: "Renderizando PDF",
    //                 );
    //             }
    //           },
    //           count: 3,
    //           width: 192,
    //           height: 48,
    //         ))
    //         : null,
    // actions: [
    //   IconButton(
    //     onPressed: () {
    //       // @todo Use open_dir to open the report's directory
    //       // OpenFile.open();
    //     },
    //     icon: Icon(Icons.remove_red_eye_outlined),
    //   ),
    // ],

    return FullscreenLoadingOverlay(
      callback: _loadReport,
      errorScreen: ErrorPage(),
      loadingScreen: LoadingPage(
        messages: [
          "Abriendo reporte",
          "Cargando imágenes",
          "Recordando configuración",
        ],
        title: "Cargando reporte",
      ),
      state: report,
      builder:
          (ReportClass report) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 128.0,
                vertical: 64,
              ),
              child: Column(
                spacing: 32,
                children: [
                  InputComponent(
                    label: "Nombre del reporte",
                    hint: "Ingrese el nombre del reporte",
                    controller: reportNameController,
                  ),
                  ...(report!.slides.map((slide) {
                    return buildSlideEditor(
                      slide,
                      _changeSlideData,
                      _editSlide,
                    );
                  }).toList()),
                ],
              ),
            ),
          ),
    );
  }
}
