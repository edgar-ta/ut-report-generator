import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';

enum SelectionMode { one, many }

enum ChartingMode { chart, superChart, none }

class FilterRecord {
  PivotTableLevel level;
  List<String> selectedValues;
  List<String> possibleValues;
  SelectionMode selectionMode;
  ChartingMode chartingMode;

  FilterRecord({
    required this.level,
    required this.selectedValues,
    required this.possibleValues,
    required this.selectionMode,
    required this.chartingMode,
  });

  FilterRecord copyWith({
    PivotTableLevel? level,
    List<String>? selectedValues,
    List<String>? possibleValues,
    SelectionMode? selectionMode,
    ChartingMode? chartingMode,
  }) {
    return FilterRecord(
      level: level ?? this.level,
      selectedValues: selectedValues ?? List.from(this.selectedValues),
      possibleValues: possibleValues ?? List.from(this.possibleValues),
      selectionMode: selectionMode ?? this.selectionMode,
      chartingMode: chartingMode ?? this.chartingMode,
    );
  }
}
