import 'package:ut_report_generator/models/response/success_response.dart';

class FileResponse extends SuccessResponse {
  String filepath;
  String? preview;

  FileResponse({required super.message, required this.filepath, this.preview});

  factory FileResponse.fromJson(Map<String, dynamic> json) {
    return FileResponse(
      message: json['message'],
      filepath: json['filepath'],
      preview: json['preview'],
    );
  }
}
