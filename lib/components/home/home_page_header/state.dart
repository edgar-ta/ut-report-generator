import 'package:ut_report_generator/models/response/hello_request_response.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class HomePageHeaderState {
  FutureStatus status;
  HelloRequestResponse? response;

  HomePageHeaderState({required this.status, required this.response});
}
