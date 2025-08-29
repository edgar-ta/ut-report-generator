import 'package:ut_report_generator/api/send_request.dart';

Future<Map<String, dynamic>> reorderFilter({
  required String report,
  required String pivotTable,
  required int oldIndex,
  required int newIndex,
}) {
  return sendRequest(
    route: "pivot_table/reorder_filter",
    body: {
      "report": report,
      "pivot_table": pivotTable,
      "old_index": oldIndex,
      "new_index": newIndex,
    },
    callback: (json) => json,
  );
}
