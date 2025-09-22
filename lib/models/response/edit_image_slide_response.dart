// ignore: camel_case_types
class EditImageSlide_Response {
  String preview;

  EditImageSlide_Response({required this.preview});

  factory EditImageSlide_Response.fromJson(Map<String, dynamic> json) {
    return EditImageSlide_Response(preview: json['preview'] as String);
  }
}
