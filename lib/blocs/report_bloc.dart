import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/api/report/self.dart' as report_api;

class ReportBloc {
  ReportClass initialReport;
  void Function(ReportClass Function(ReportClass)) setReport;

  ReportBloc({required this.initialReport, required this.setReport});

  Future<void> renameReport(String name) async {
    setReport((report) => report.copyWith(reportName: name));
    await report_api.renameReport(report: initialReport.identifier, name: name);
  }
}
