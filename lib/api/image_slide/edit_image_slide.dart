import 'package:ut_report_generator/api/send_request.dart';

Future<EditSlide_Response> editSlide({
  required String reportDirectory,
  required String slideId,
  required dynamic arguments,
}) {
  return sendRequest(
    route: "edit_slide",
    body: {
      "report_directory": reportDirectory,
      "slide_id": slideId,
      "arguments": arguments,
    },
    callback: EditSlide_Response.fromJson,
  );
}

// ignore: camel_case_types
class EditSlide_Response {
  String preview;

  EditSlide_Response({required this.preview});

  static EditSlide_Response fromJson(Map<String, dynamic> json) {
    return EditSlide_Response(preview: json['preview'] as String);
  }
}
