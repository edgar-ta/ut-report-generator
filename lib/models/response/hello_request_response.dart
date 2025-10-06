class HelloRequestResponse {
  String message;

  HelloRequestResponse({required this.message});

  static HelloRequestResponse fromJson(Map<String, dynamic> json) {
    return HelloRequestResponse(message: json['message'] as String);
  }
}
