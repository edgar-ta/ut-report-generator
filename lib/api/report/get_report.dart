import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report.dart';

Future<ReportClass> getReport({required String identifier}) async {
  return sendRequest(
    route: "report/get",
    callback: ReportClass.fromJson,
    body: {"report": identifier},
  );
}
