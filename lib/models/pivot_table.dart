enum AggregateFunctionType { count, average, min, max }

enum FilterFunctionType { failedStudents, approvedStudents, allStudents }

enum SlideCategory { pivotTable, image }

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

class DataSource {
  final List<String> files;
  final String? mergedFile;

  DataSource({required this.files, this.mergedFile});

  Map<String, dynamic> toJson() {
    return {"files": files, "merged_file": mergedFile};
  }

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      files: List<String>.from(json["files"]),
      mergedFile: json["merged_file"],
    );
  }

  DataSource copyWith({List<String>? files, String? mergedFile}) {
    return DataSource(
      files: files ?? this.files,
      mergedFile: mergedFile ?? this.mergedFile,
    );
  }
}

class PivotTable {
  final String name;
  final String identifier;
  final DateTime creationDate;
  final DateTime lastEdit;
  final SlideCategory category;
  final String? preview;
  final DataSource source;
  final List<CustomIndexer> arguments;
  final List<CustomIndexer> parameters;
  final Map<String, dynamic> data;
  final AggregateFunctionType aggregateFunction;
  final FilterFunctionType filterFunction;
  final SlideCategory mode;

  PivotTable({
    required this.name,
    required this.identifier,
    required this.creationDate,
    required this.lastEdit,
    this.preview,
    required this.source,
    required this.arguments,
    required this.parameters,
    required this.data,
    required this.aggregateFunction,
    required this.filterFunction,
    required this.mode,
  }) : category = SlideCategory.pivotTable;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "identifier": identifier,
      "creation_date": creationDate.toIso8601String(),
      "last_edit": lastEdit.toIso8601String(),
      "category": category.name,
      "preview": preview,
      "source": source.toJson(),
      "arguments": arguments.map((a) => a.toJson()).toList(),
      "parameters": parameters.map((p) => p.toJson()).toList(),
      "data": data,
      "aggregate_function": aggregateFunction.name,
      "filter_function": filterFunction.name,
      "mode": mode.name,
    };
  }

  factory PivotTable.fromJson(Map<String, dynamic> json) {
    return PivotTable(
      name: json["name"],
      identifier: json["identifier"],
      creationDate: DateTime.parse(json["creation_date"]),
      lastEdit: DateTime.parse(json["last_edit"]),
      preview: json["preview"],
      source: DataSource.fromJson(json["source"]),
      arguments:
          (json["arguments"] as List)
              .map((e) => CustomIndexer.fromJson(e))
              .toList(),
      parameters:
          (json["parameters"] as List)
              .map((e) => CustomIndexer.fromJson(e))
              .toList(),
      data: Map<String, dynamic>.from(json["data"]),
      aggregateFunction: AggregateFunctionType.values.firstWhere(
        (e) => e.name == json["aggregate_function"],
      ),
      filterFunction: FilterFunctionType.values.firstWhere(
        (e) => e.name == json["filter_function"],
      ),
      mode: SlideCategory.values.firstWhere((e) => e.name == json["mode"]),
    );
  }

  PivotTable copyWith({
    String? name,
    String? identifier,
    DateTime? creationDate,
    DateTime? lastEdit,
    String? preview,
    DataSource? source,
    List<CustomIndexer>? arguments,
    List<CustomIndexer>? parameters,
    Map<String, dynamic>? data,
    AggregateFunctionType? aggregateFunction,
    FilterFunctionType? filterFunction,
    SlideCategory? mode,
  }) {
    return PivotTable(
      name: name ?? this.name,
      identifier: identifier ?? this.identifier,
      creationDate: creationDate ?? this.creationDate,
      lastEdit: lastEdit ?? this.lastEdit,
      preview: preview ?? this.preview,
      source: source ?? this.source,
      arguments: arguments ?? this.arguments,
      parameters: parameters ?? this.parameters,
      data: data ?? this.data,
      aggregateFunction: aggregateFunction ?? this.aggregateFunction,
      filterFunction: filterFunction ?? this.filterFunction,
      mode: mode ?? this.mode,
    );
  }
}
