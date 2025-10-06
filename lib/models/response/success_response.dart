class SuccessResponse {
  String message;
  SuccessResponse({required this.message});

  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(message: json['message'] as String);
  }
}
