import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_data.dart';

Future<EditPivotTable_Response> editPivotTable({
  required String report,
  required String pivotTable,
  required List<DataFilter> filters,
}) {
  return sendRequest(
    route: "pivot_table/edit",
    body: {
      "report": report,
      "pivot_table": pivotTable,
      "filters": filters.map((filter) => filter.toJson()).toList(),
    },
    callback: EditPivotTable_Response.fromJson,
  );
}

// ignore: camel_case_types
class EditPivotTable_Response {
  final List<DataFilter> filters;
  final PivotData data;

  EditPivotTable_Response({required this.filters, required this.data});

  factory EditPivotTable_Response.fromJson(Map<String, dynamic> json) {
    return EditPivotTable_Response(
      filters:
          (json['filters'] as List<dynamic>)
              .map((e) => DataFilter.fromJson(e as Map<String, dynamic>))
              .toList(),
      data: PivotData.fromJson(json['data']),
    );
  }
}
