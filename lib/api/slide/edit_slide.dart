import 'package:ut_report_generator/models/asset_class.dart';
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
  List<AssetClass> assets;
  String preview;
  String key;

  EditSlide_Response({
    required this.assets,
    required this.preview,
    required this.key,
  });

  static EditSlide_Response fromJson(Map<String, dynamic> json) {
    return EditSlide_Response(
      assets:
          (json['assets'] as List<dynamic>)
              .map((asset) => AssetClass.fromJson(asset))
              .toList(),
      preview: json['preview'] as String,
      key: json['key'] as String,
    );
  }
}
