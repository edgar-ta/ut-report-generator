class AssetClass {
  String name;
  String value;
  String type;

  AssetClass({required this.name, required this.value, required this.type});

  factory AssetClass.fromJson(Map<String, dynamic> json) {
    return AssetClass(
      name: json['name'] as String,
      value: json['value'] as String,
      type: json['type'] as String,
    );
  }
}
