import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/success_response.dart';

Future<SuccessResponse> renameSlide({
  required String report,
  required String slide,
  required String title,
}) {
  return sendRequest(
    route: "slide/rename",
    body: {'report': report, 'slide': slide, 'title': title},
    callback: SuccessResponse.fromJson,
  );
}
