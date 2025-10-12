import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/success_response.dart';

Future<SuccessResponse> deleteSlide({
  required String slideshow,
  required String slide,
}) {
  return sendRequest(
    route: "slide/delete",
    callback: SuccessResponse.fromJson,
    body: {'report': slideshow, 'slide': slide},
  );
}
