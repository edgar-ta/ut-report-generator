import 'package:ut_report_generator/models/asset_class.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<ChangeSlideData_Response> changeSlideData({
  required List<String> dataFiles,
  required String reportDirectory,
  required String slideId,
}) {
  return sendRequest<ChangeSlideData_Response>(
    route: "change_slide_data",
    callback: (json) => ChangeSlideData_Response.fromJson(json),
    body: {
      "data_files": dataFiles,
      "report_directory": reportDirectory,
      "slide_id": slideId,
    },
  );
}

// ignore: camel_case_types
class ChangeSlideData_Response {
  List<AssetClass> assets;
  String preview;
  String key;

  ChangeSlideData_Response({
    required this.assets,
    required this.preview,
    required this.key,
  });

  factory ChangeSlideData_Response.fromJson(Map<String, dynamic> json) {
    return ChangeSlideData_Response(
      assets:
          (json['assets'] as List)
              .map((asset) => AssetClass.fromJson(asset))
              .toList(),
      preview: json['preview'] as String,
      key: json['key'] as String,
    );
  }
}
