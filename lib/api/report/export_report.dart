import 'package:ut_report_generator/api/report/compile_report.dart';
import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/file_response.dart';

Future<FileResponse> exportReport({required String report}) {
  return sendRequest(
    route: "report/export",
    body: {"report": report},
    callback: FileResponse.fromJson,
  );
}
