import 'package:ut_report_generator/api/types/asset_type.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<EditSlide_Response> editSlide(
  String reportDirectory,
  String slideId,
  dynamic arguments,
) {
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
  List<AssetType> assets;
  String preview;

  EditSlide_Response({required this.assets, required this.preview});

  static EditSlide_Response fromJson(Map<String, dynamic> json) {
    return EditSlide_Response(
      assets:
          (json['assets'] as List<dynamic>)
              .map((asset) => AssetType.fromJson(asset))
              .toList(),
      preview: json['preview'] as String,
    );
  }
}
