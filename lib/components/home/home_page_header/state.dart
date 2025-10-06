import 'package:ut_report_generator/components/home/startup_button/state.dart';
import 'package:ut_report_generator/models/response/hello_request_response.dart';
import 'package:ut_report_generator/pages/home/_main.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class HomePageHeaderState {
  final FutureStatus status;
  final HelloRequestResponse? response;
  final StartupButtonState<StartupOption> startupButtonState;

  HomePageHeaderState({
    required this.status,
    required this.response,
    required this.startupButtonState,
  });

  HomePageHeaderState copyWith({
    FutureStatus? status,
    required HelloRequestResponse? response,
    StartupButtonState<StartupOption>? startupButtonState,
  }) {
    return HomePageHeaderState(
      status: status ?? this.status,
      response: response ?? this.response,
      startupButtonState: startupButtonState ?? this.startupButtonState,
    );
  }
}
