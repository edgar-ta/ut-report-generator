// ignore: camel_case_types
class SuccessResponse {
  String message;

  SuccessResponse({required this.message});

  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(message: json['message']);
  }
}
