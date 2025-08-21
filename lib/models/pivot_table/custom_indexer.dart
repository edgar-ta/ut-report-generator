class CustomIndexer {
  final String level;
  final List<String> values;

  CustomIndexer({required this.level, required this.values});

  Map<String, dynamic> toJson() {
    return {"level": level, "values": values};
  }

  factory CustomIndexer.fromJson(Map<String, dynamic> json) {
    return CustomIndexer(
      level: json["level"],
      values: List<String>.from(json["values"]),
    );
  }

  CustomIndexer copyWith({String? level, List<String>? values}) {
    return CustomIndexer(
      level: level ?? this.level,
      values: values ?? this.values,
    );
  }

  @override
  String toString() => "CustomIndexer(level: $level, values: $values)";
}
