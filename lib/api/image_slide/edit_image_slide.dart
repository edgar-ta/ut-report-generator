import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/edit_image_slide_response.dart';

Future<EditImageSlideResponse> editSlide({
  required String slideshow,
  required String imageSlide,
  required String parameterName,
  required String parameterValue,
}) {
  return sendRequest(
    route: "image_slide/edit",
    body: {
      "report": slideshow,
      "image_slide": imageSlide,
      "parameter_name": parameterName,
      "parameter_value": parameterValue,
    },
    callback: EditImageSlideResponse.fromJson,
  );
}
