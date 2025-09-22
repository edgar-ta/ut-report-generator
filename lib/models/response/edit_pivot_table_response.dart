import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_data.dart';

// ignore: camel_case_types
class EditPivotTable_Response {
  final List<DataFilter> filters;
  final PivotData data;
  final String preview;

  EditPivotTable_Response({
    required this.filters,
    required this.data,
    required this.preview,
  });

  factory EditPivotTable_Response.fromJson(Map<String, dynamic> json) {
    return EditPivotTable_Response(
      filters:
          (json['filters'] as List<dynamic>)
              .map((e) => DataFilter.fromJson(e as Map<String, dynamic>))
              .toList(),
      data: PivotData.fromJson(json['data']),
      preview: json['preview'] as String,
    );
  }
}
