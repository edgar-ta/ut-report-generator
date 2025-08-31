import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_data.dart';

Future<PivotData> setCharts({
  required String report,
  required String pivotTable,
  int? chart,
  int? superChart,
}) {
  return sendRequest(
    route: "pivot_table/set_charts",
    body: {
      "report": report,
      "pivot_table": pivotTable,
      "chart": chart,
      "super_chart": superChart,
    },
    callback: PivotData.fromJson,
  );
}
