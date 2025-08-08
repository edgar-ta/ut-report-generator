class AssetType {
  String name;
  String value;
  String type;

  AssetType({required this.name, required this.value, required this.type});

  factory AssetType.fromJson(Map<String, dynamic> json) {
    return AssetType(
      name: json['name'] as String,
      value: json['value'] as String,
      type: json['type'] as String,
    );
  }
}
