import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/file_response.dart';

Future<FileResponse> renameSlide({
  required String report,
  required String slide,
  required String title,
}) {
  return sendRequest(
    route: "slide/rename",
    body: {'report': report, 'slide': slide, 'title': title},
    callback: FileResponse.fromJson,
  );
}
