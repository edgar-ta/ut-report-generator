import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/selection_mode.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';

class DataFilter {
  PivotTableLevel level;
  List<String> selectedValues;
  List<String> possibleValues;
  SelectionMode selectionMode;
  ChartingMode chartingMode;

  DataFilter({
    required this.level,
    required this.selectedValues,
    required this.possibleValues,
    required this.selectionMode,
    required this.chartingMode,
  });

  DataFilter copyWith({
    PivotTableLevel? level,
    List<String>? selectedValues,
    List<String>? possibleValues,
    SelectionMode? selectionMode,
    ChartingMode? chartingMode,
  }) {
    return DataFilter(
      level: level ?? this.level,
      selectedValues: selectedValues ?? List.from(this.selectedValues),
      possibleValues: possibleValues ?? List.from(this.possibleValues),
      selectionMode: selectionMode ?? this.selectionMode,
      chartingMode: chartingMode ?? this.chartingMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "level": level.name,
      "selectedValues": selectedValues,
      "possibleValues": possibleValues,
      "selectionMode": selectionMode.name,
      "chartingMode": chartingMode.name,
    };
  }

  factory DataFilter.fromJson(Map<String, dynamic> json) {
    return DataFilter(
      level: PivotTableLevel.values.byName(json["level"]),
      selectedValues: List<String>.from(json["selectedValues"] ?? []),
      possibleValues: List<String>.from(json["possibleValues"] ?? []),
      selectionMode: SelectionMode.values.byName(json["selectionMode"]),
      chartingMode: ChartingMode.values.byName(json["chartingMode"]),
    );
  }
}
