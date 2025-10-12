import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_data.dart';

class EditPivotTableResponse {
  final List<DataFilter> filters;
  final PivotData data;
  final String preview;

  EditPivotTableResponse({
    required this.filters,
    required this.data,
    required this.preview,
  });

  factory EditPivotTableResponse.fromJson(Map<String, dynamic> json) {
    return EditPivotTableResponse(
      filters:
          (json['filters'] as List<dynamic>)
              .map((e) => DataFilter.fromJson(e as Map<String, dynamic>))
              .toList(),
      data: PivotData.fromJson(json['data']),
      preview: json['preview'] as String,
    );
  }
}
