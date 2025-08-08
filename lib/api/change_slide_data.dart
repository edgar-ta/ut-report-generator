import 'package:ut_report_generator/api/types/asset_type.dart';
import 'package:ut_report_generator/api/send_request.dart';

Future<ChangeSlideData_Response> changeSlideData({
  required String newDataFile,
  required String reportDirectory,
  required String slideId,
}) {
  return sendRequest<ChangeSlideData_Response>(
    route: "change_slide_data",
    callback: (json) => ChangeSlideData_Response.fromJson(json),
    body: {
      "data_file": newDataFile,
      "report_directory": reportDirectory,
      "slide_id": slideId,
    },
  );
}

// ignore: camel_case_types
class ChangeSlideData_Response {
  List<AssetType> assets;
  String preview;

  ChangeSlideData_Response({required this.assets, required this.preview});

  factory ChangeSlideData_Response.fromJson(Map<String, dynamic> json) {
    return ChangeSlideData_Response(
      assets:
          (json['assets'] as List)
              .map((asset) => AssetType.fromJson(asset))
              .toList(),
      preview: json['preview'] as String,
    );
  }
}
