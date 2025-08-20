import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report.dart';

Future<ReportClass> importReport({required String reportFile}) async {
  return sendRequest(
    route: "report/import",
    callback: ReportClass.fromJson,
    body: {"report_file": reportFile},
  );
}
