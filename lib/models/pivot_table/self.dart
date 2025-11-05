import 'package:ut_report_generator/models/pivot_table/aggregate_function_type.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/data_source.dart';
import 'package:ut_report_generator/models/pivot_table/filter_function_type.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_data.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';

class PivotTable extends Slide {
  final String barePreview;
  final DataSource source;
  final List<DataFilter> filters;
  final List<PivotTableLevel> filtersOrder;
  final PivotTableData data;
  final AggregateFunctionType aggregateFunction;
  final FilterFunctionType filterFunction;
  final bool automaticTitle;

  PivotTable({
    required super.title,
    required super.identifier,
    required super.creationDate,
    required super.lastEdit,
    required super.preview,
    required this.barePreview,
    required this.source,
    required this.filters,
    required this.filtersOrder,
    required this.data,
    required this.aggregateFunction,
    required this.filterFunction,
    required this.automaticTitle,
  }) : super(category: SlideCategory.pivotTable);

  Map<String, dynamic> toJson() {
    return {
      ...super.toMap(),
      "bare_preview": barePreview,
      "source": source.toJson(),
      "filters": filters.map((f) => f.toJson()).toList(),
      "filters_order": filtersOrder.map((value) => value.name).toList(),
      "data": data,
      "aggregate_function": aggregateFunction.name,
      "filter_function": filterFunction.name,
    };
  }

  factory PivotTable.fromJson(Map<String, dynamic> json) {
    final title = json["title"];
    final identifier = json["identifier"];
    final creationDate = DateTime.parse(json["creation_date"]);
    final lastEdit = DateTime.parse(json["last_edit"]);
    final preview = json["preview"];
    final barePreview = json["bare_preview"];
    final source = DataSource.fromJson(json["source"]);
    final filters =
        (json["filters"] as List).map((e) => DataFilter.fromJson(e)).toList();
    final filtersOrder =
        (json["filters_order"] as List)
            .map((e) => PivotTableLevel.values.byName(e))
            .toList();
    final data = PivotTableData.fromJson(json["data"]);
    final aggregateFunction = AggregateFunctionType.values.byName(
      json["aggregate_function"],
    );
    final filterFunction = FilterFunctionType.values.byName(
      json["filter_function"],
    );

    return PivotTable(
      title: title,
      identifier: identifier,
      creationDate: creationDate,
      lastEdit: lastEdit,
      preview: preview,
      barePreview: barePreview,
      source: source,
      filters: filters,
      filtersOrder: filtersOrder,
      data: data,
      aggregateFunction: aggregateFunction,
      filterFunction: filterFunction,
      automaticTitle: true,
    );
  }

  PivotTable copyWith({
    String? title,
    String? identifier,
    DateTime? creationDate,
    DateTime? lastEdit,
    String? barePreview,
    String? preview,
    DataSource? source,
    List<DataFilter>? filters,
    List<PivotTableLevel>? filtersOrder,
    PivotTableData? data,
    AggregateFunctionType? aggregateFunction,
    FilterFunctionType? filterFunction,
    bool? automaticTitle,
  }) {
    return PivotTable(
      title: title ?? this.title,
      identifier: identifier ?? this.identifier,
      creationDate: creationDate ?? this.creationDate,
      lastEdit: lastEdit ?? this.lastEdit,
      preview: preview ?? this.preview,
      barePreview: barePreview ?? this.barePreview,
      source: source ?? this.source,
      filters: filters ?? this.filters,
      filtersOrder: filtersOrder ?? this.filtersOrder,
      data: data ?? this.data,
      aggregateFunction: aggregateFunction ?? this.aggregateFunction,
      filterFunction: filterFunction ?? this.filterFunction,
      automaticTitle: automaticTitle ?? this.automaticTitle,
    );
  }
}
