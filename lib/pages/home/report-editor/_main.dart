import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/api/image_slide/edit_image_slide.dart';
import 'package:ut_report_generator/api/report/export_report.dart';
import 'package:ut_report_generator/api/file_response.dart';
import 'package:ut_report_generator/api/report/render_report.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/report.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/components/common_appbar.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/error_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/loading_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/widget.dart';
import 'package:ut_report_generator/components/input_component.dart';
import 'package:ut_report_generator/pages/home/report-editor/failure_section/widget.dart';
import 'package:ut_report_generator/pages/home/report-editor/image_slide_section/widget.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/widget.dart';
import 'package:ut_report_generator/pages/home/report-editor/progress_alert_dialog.dart';
import 'package:ut_report_generator/pages/home/report-editor/render_button.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';

Widget buildSlideEditor(
  PivotTable slide,
  Future<void> Function(String slideId, List<File> dataFiles) changeSlideData,
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide,
) {
  switch (slide.kind) {
    case ImageSlideKind.failureRate:
      return FailureSection(
        slideData: slide,
        editSlide: editSlide,
        changeSlideData: changeSlideData,
      );
    case ImageSlideKind.average:
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
                ..setFab(null);
              context.pop();
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
    String? preview,
    Map<String, dynamic>? arguments,
  }) {
    setState(() {
      var slides =
          report!.slides.map((slide) {
            if (slide.identifier == slideId) {
              return slide.copyWith(arguments: arguments, preview: preview);
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
      _setSlideData(slideId: slideId, preview: value.preview);
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
        preview: value.preview,
        arguments: arguments,
      );
    });
  }

  Future<RenderReport_Response> _renderReport() {
    return renderReport(reportDirectory: report!.reportDirectory);
  }

  Future<ExportReport_Response> _exportReport() {
    return exportReport(identifier: report!.reportDirectory);
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 64),
        child: Column(
          children: [
            ...(report!.slides.map((slide) {
              if (slide is PivotTable) {
                return PivotTableSection(
                  initialTable: slide,
                  editSlide: editSlide,
                  changeSlideData: changeSlideData,
                  editionPaneBuilder: editionPaneBuilder,
                  metadataPane: metadataPane,
                );
              }
              if (slide is ImageSlide) {
                return ImageSlideSection(initialSlide: slide);
              }
              return Text("Tipo de slide inválido");
            }).toList()),
          ],
        ),
      ),
    );
  }
}
