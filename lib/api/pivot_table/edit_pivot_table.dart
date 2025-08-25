import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/pivot_table/custom_indexer.dart';

Future<EditPivotTable_Response> editPivotTable({
  required String report,
  required String pivotTable,
  required List<CustomIndexer> arguments,
}) {
  return sendRequest(
    route: "pivot_table/edit",
    body: {
      "report": report,
      "pivot_table": pivotTable,
      "arguments": arguments.map((a) => a.toJson()).toList(),
    },
    callback: EditPivotTable_Response.fromJson,
  );
}

// ignore: camel_case_types
class EditPivotTable_Response {
  final List<CustomIndexer> parameters;
  final List<CustomIndexer> arguments;
  final Map<String, Map<String, double>> data;

  EditPivotTable_Response({
    required this.parameters,
    required this.arguments,
    required this.data,
  });

  factory EditPivotTable_Response.fromJson(Map<String, dynamic> json) {
    return EditPivotTable_Response(
      parameters:
          (json['parameters'] as List<dynamic>)
              .map((e) => CustomIndexer.fromJson(e as Map<String, dynamic>))
              .toList(),
      arguments:
          (json['arguments'] as List<dynamic>)
              .map((e) => CustomIndexer.fromJson(e as Map<String, dynamic>))
              .toList(),
      data: (json["data"] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (innerKey, innerValue) => MapEntry(
              innerKey,
              (innerValue as num).toDouble(), // asegura double
            ),
          ),
        ),
      ),
    );
  }
}
