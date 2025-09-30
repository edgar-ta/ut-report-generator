import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/pivot_table/create_pivot_table.dart'
    as pivot_table_api;
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/api/report/self.dart' as report_api;
import 'package:ut_report_generator/models/report/visualization_mode.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';

class SlideshowEditorBloc {
  Slideshow initialReport;
  void Function(Slideshow Function(Slideshow)) setReport;

  SlideshowEditorBloc({required this.initialReport, required this.setReport});

  Future<void> rename(String name) async {
    setReport((report) => report.copyWith(reportName: name));
    await report_api.renameReport(report: initialReport.identifier, name: name);
  }

  Future<void> toggleSlideshowMode() async {
    setReport(
      (report) => report.copyWith(
        visualizationMode:
            report.visualizationMode == VisualizationMode.chartsOnly
                ? VisualizationMode.asReport
                : VisualizationMode.chartsOnly,
      ),
    );
    await report_api.toggleModeOfReport(report: initialReport.identifier);
  }

  Future<void> addPivotTable({
    required List<String> files,
    required ScrollController controller,
  }) async {
    await pivot_table_api
        .createPivotTable(report: initialReport.identifier, dataFiles: files)
        .then((value) {
          setReport(
            (report) =>
                report.copyWith(slides: copyWithAdded(report.slides, value)),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.hasClients) {
              controller.animateTo(
                controller.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }
          });
        });
  }
}
