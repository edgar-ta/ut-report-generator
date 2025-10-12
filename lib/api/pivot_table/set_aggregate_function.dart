import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/pivot_table/aggregate_function_type.dart';
import 'package:ut_report_generator/models/response/edit_pivot_table_response.dart';

Future<EditPivotTableResponse> setAggregateFunction({
  required String slideshow,
  required String pivotTable,
  required AggregateFunctionType aggregateFunction,
}) {
  return sendRequest(
    route: "pivot_table/set_aggregate_function",
    callback: EditPivotTableResponse.fromJson,
    body: {
      'report': slideshow,
      'pivot_table': pivotTable,
      'aggregate_function': aggregateFunction.name,
    },
  );
}
