import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/success_response.dart';

Future<SuccessResponse> deleteSlideshow({required String slideshow}) {
  return sendRequest(
    route: "report/delete",
    callback: SuccessResponse.fromJson,
    body: {'report': slideshow},
  );
}
