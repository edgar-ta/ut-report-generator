import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/api/report/self.dart' as report_api;
import 'package:ut_report_generator/models/report/visualization_mode.dart';

class ReportBloc {
  ReportClass initialReport;
  void Function(ReportClass Function(ReportClass)) setReport;

  ReportBloc({required this.initialReport, required this.setReport});

  Future<void> rename(String name) async {
    setReport((report) => report.copyWith(reportName: name));
    await report_api.renameReport(report: initialReport.identifier, name: name);
  }

  Future<void> toggleMode() async {
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
}
