import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/edit_image_slide_response.dart';

Future<EditImageSlide_Response> editSlide({
  required String report,
  required String imageSlide,
  required String parameterName,
  required String parameterValue,
}) {
  return sendRequest(
    route: "image_slide/edit",
    body: {
      "report": report,
      "image_slide": imageSlide,
      "parameter_name": parameterName,
      "parameter_value": parameterValue,
    },
    callback: EditImageSlide_Response.fromJson,
  );
}
