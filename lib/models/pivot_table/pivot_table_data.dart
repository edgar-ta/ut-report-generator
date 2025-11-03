import 'dart:ui';

sealed class PivotTableData {
  const PivotTableData();

  static PivotTableData fromJson(dynamic json) {
    dynamic result;

    if ((json as List).every((value) => (value as Map).containsKey("rods"))) {
      result = PivotTableRodGroupClass.fromJson(json);
    } else if ((json).every((value) => (value as Map).containsKey("value"))) {
      result = PivotTableRodClass.fromJson(json);
    } else {
      throw ArgumentError("Formato de datos no válido para PivotData");
    }
    return result;
  }
}

class PivotTableRod {
  String key;
  double value;
  int index;
  bool missing;
  Color color;

  PivotTableRod({
    required this.key,
    required this.value,
    required this.index,
    required this.missing,
    required this.color,
  });

  factory PivotTableRod.fromJson(Map<String, dynamic> json) {
    final key = json['key'];
    final value = (json['value'] as num).toDouble();
    final missing = json['missing'] as bool;
    final index = (json['index'] as num).toInt();

    String colorString = json['color'];
    final components =
        colorString
            .split(",")
            .map((element) => (num.parse(element)).toInt())
            .toList();
    final color = Color.fromARGB(
      255,
      components[0],
      components[1],
      components[2],
    );

    return PivotTableRod(
      key: key,
      value: value,
      missing: missing,
      index: index,
      color: color,
    );
  }
}

class PivotTableRodClass extends PivotTableData {
  final List<PivotTableRod> contents;

  const PivotTableRodClass(this.contents);

  factory PivotTableRodClass.fromJson(dynamic json) {
    return PivotTableRodClass(
      (json as List)
          .map(
            (element) =>
                PivotTableRod.fromJson(element as Map<String, dynamic>),
          )
          .toList()
        ..sort((a, b) => a.index - b.index),
    );
  }
}

class PivotTableRodGroup {
  String key;
  List<PivotTableRod> rods;
  int index;

  PivotTableRodGroup({
    required this.key,
    required this.rods,
    required this.index,
  });

  factory PivotTableRodGroup.fromJson(Map<String, dynamic> json) {
    return PivotTableRodGroup(
      key: json['key'],
      rods:
          (json['rods'] as List)
              .map(
                (element) =>
                    PivotTableRod.fromJson(element as Map<String, dynamic>),
              )
              .toList()
            ..sort((a, b) => a.index - b.index),
      index: (json['index'] as num).toInt(),
    );
  }
}

class PivotTableRodGroupClass extends PivotTableData {
  final List<PivotTableRodGroup> contents;

  const PivotTableRodGroupClass(this.contents);

  factory PivotTableRodGroupClass.fromJson(dynamic json) {
    return PivotTableRodGroupClass(
      (json as List)
          .map(
            (element) =>
                PivotTableRodGroup.fromJson(element as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
