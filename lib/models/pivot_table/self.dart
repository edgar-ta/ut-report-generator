import 'package:ut_report_generator/models/pivot_table/aggregate_function_type.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/data_source.dart';
import 'package:ut_report_generator/models/pivot_table/filter_function_type.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_data.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';

class PivotTable implements Slide {
  final String name;

  @override
  final String identifier;
  final DateTime creationDate;
  final DateTime lastEdit;
  final SlideCategory category;
  final String? preview;
  final DataSource source;
  final List<DataFilter> filters;
  final List<PivotTableLevel> filtersOrder;
  final PivotData data;
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
    required this.filters,
    required this.filtersOrder,
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
      "filters": filters.map((f) => f.toJson()).toList(),
      "filters_order": filtersOrder.map((value) => value.name).toList(),
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
      filters:
          (json["filters"] as List).map((e) => DataFilter.fromJson(e)).toList(),
      filtersOrder:
          (json["filters_order"] as List)
              .map((e) => PivotTableLevel.values.byName(e))
              .toList(),
      data: PivotData.fromJson(json["data"]),
      aggregateFunction: AggregateFunctionType.values.byName(
        json["aggregate_function"],
      ),
      filterFunction: FilterFunctionType.values.byName(json["filter_function"]),
      mode: SlideCategory.values.byName(json["mode"]),
    );
  }

  PivotTable copyWith({
    String? name,
    String? identifier,
    DateTime? creationDate,
    DateTime? lastEdit,
    String? preview,
    DataSource? source,
    List<DataFilter>? filters,
    List<PivotTableLevel>? filtersOrder,
    PivotData? data,
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
      filters: filters ?? this.filters,
      filtersOrder: filtersOrder ?? this.filtersOrder,
      data: data ?? this.data,
      aggregateFunction: aggregateFunction ?? this.aggregateFunction,
      filterFunction: filterFunction ?? this.filterFunction,
      mode: mode ?? this.mode,
    );
  }
}
