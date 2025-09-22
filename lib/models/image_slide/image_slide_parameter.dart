class ImageSlideParameter {
  String readableName;
  String value;
  String type;

  ImageSlideParameter({
    required this.readableName,
    required this.value,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {'readable_name': readableName, 'value': value, 'type': type};
  }

  factory ImageSlideParameter.fromJson(Map<String, dynamic> json) {
    return ImageSlideParameter(
      readableName: json['readable_name'],
      value: json['value'],
      type: json['type'],
    );
  }

  ImageSlideParameter copyWith({
    String? readableName,
    String? value,
    String? type,
  }) {
    return ImageSlideParameter(
      readableName: readableName ?? this.readableName,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }
}
