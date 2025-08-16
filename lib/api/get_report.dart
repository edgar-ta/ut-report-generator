import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/types/report_class.dart';

Future<ReportClass> getReport({required String reportDirectory}) async {
  return sendRequest(
    route: "get_report",
    callback: ReportClass.fromJson,
    body: {"report_directory": reportDirectory},
  );
}
