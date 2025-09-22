import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/response/edit_pivot_table_response.dart';

Future<EditPivotTable_Response> deleteFilter({
  required String report,
  required String pivotTable,
  required int filter,
}) {
  return sendRequest(
    route: "pivot_table/filter/delete",
    body: {"report": report, "pivot_table": pivotTable, "filter": filter},
    callback: EditPivotTable_Response.fromJson,
  );
}
