// ignore: camel_case_types
class EditImageSlideResponse {
  String preview;

  EditImageSlideResponse({required this.preview});

  factory EditImageSlideResponse.fromJson(Map<String, dynamic> json) {
    return EditImageSlideResponse(preview: json['preview'] as String);
  }
}
