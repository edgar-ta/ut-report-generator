sealed class PivotData {
  const PivotData();

  Map<String, dynamic> toJson();

  static PivotData fromJson(Map<String, dynamic> json) {
    if (json.values.every((value) => value is num)) {
      return FlatData.fromJson(json);
    } else if (json.values.every((value) => value is Map)) {
      return GroupedData.fromJson(json);
    } else {
      throw ArgumentError("Formato de datos no válido para PivotData");
    }
  }
}

class FlatData extends PivotData {
  final Map<String, double> data;

  const FlatData(this.data);

  @override
  Map<String, dynamic> toJson() => data;

  factory FlatData.fromJson(Map<String, dynamic> json) {
    return FlatData(json.map((k, v) => MapEntry(k, (v as num).toDouble())));
  }
}

class GroupedData extends PivotData {
  final Map<String, Map<String, double>> data;

  const GroupedData(this.data);

  @override
  Map<String, dynamic> toJson() => data;

  factory GroupedData.fromJson(Map<String, dynamic> json) {
    return GroupedData(
      json.map((k, v) {
        final inner = (v as Map<String, dynamic>).map(
          (ik, iv) => MapEntry(ik, (iv as num).toDouble()),
        );
        return MapEntry(k, inner);
      }),
    );
  }
}
