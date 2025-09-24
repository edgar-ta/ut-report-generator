import 'package:ut_report_generator/models/response/file_response.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<FileResponse> compileReport({required String report}) {
  return sendRequest(
    route: "report/compile",
    body: {"report": report},
    callback: FileResponse.fromJson,
  );
}
