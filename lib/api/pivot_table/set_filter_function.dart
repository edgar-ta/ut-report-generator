import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/pivot_table/filter_function_type.dart';
import 'package:ut_report_generator/models/response/edit_pivot_table_response.dart';

Future<EditPivotTableResponse> setFilterFunction({
  required String slideshow,
  required String pivotTable,
  required FilterFunctionType filterFunction,
}) {
  return sendRequest(
    route: "pivot_table/set_filter_function",
    callback: EditPivotTableResponse.fromJson,
    body: {
      'report': slideshow,
      'pivot_table': pivotTable,
      'filter_function': filterFunction.name,
    },
  );
}
