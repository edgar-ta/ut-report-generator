import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/report_class.dart';

Future<ReportClass> importReport({required String reportFile}) async {
  return sendRequest(
    route: "import_report",
    callback: ReportClass.fromJson,
    body: {"report_file": reportFile},
  );
}
