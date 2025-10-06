import 'package:flutter/material.dart';
import 'package:ut_report_generator/components/home/home_page_header/state.dart';
import 'package:ut_report_generator/components/home/welcome_text.dart';
import 'package:ut_report_generator/components/home/startup_button/entry.dart';
import 'package:ut_report_generator/components/home/startup_button/state.dart';
import 'package:ut_report_generator/components/home/startup_button/widget.dart';
import 'package:ut_report_generator/pages/home/_main.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class HomePageHeader extends StatelessWidget {
  final HomePageHeaderState state;
  final void Function(
    StartupButtonState<StartupOption> Function(
      StartupButtonState<StartupOption>,
    ),
  )
  setStartupButtonState;
  final void Function(StartupOption) startSlideshow;

  const HomePageHeader({
    super.key,
    required this.state,
    required this.setStartupButtonState,
    required this.startSlideshow,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: state.status == FutureStatus.pending ? 1 : 0,
          duration: Duration(milliseconds: 500),
          child: _loadingState(),
        ),
        AnimatedOpacity(
          opacity: state.status != FutureStatus.pending ? 1 : 0,
          duration: Duration(milliseconds: 250),
          child:
              state.status == FutureStatus.pending
                  ? SizedBox.shrink()
                  : (state.status == FutureStatus.success
                      ? _successState()
                      : _errorState()),
        ),
      ],
    );
  }

  Widget _successState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        WelcomeText(message: state.response!.message),
        StartupButton<StartupOption>(
          entries: [
            StartupButtonEntry(
              value: StartupOption.createReport,
              title: "Crear reporte",
              icon: Icons.document_scanner,
            ),
            StartupButtonEntry(
              value: StartupOption.createVisualization,
              title: "Crear visualización",
              icon: Icons.bar_chart,
            ),
            StartupButtonEntry(
              value: StartupOption.importZip,
              title: "Importar .ZIP",
              icon: Icons.import_export,
            ),
          ],
          state: state.startupButtonState,
          setState: setStartupButtonState,
          onValueSelected: startSlideshow,
        ),
      ],
    );
  }

  Widget _loadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        Container(width: 450, height: 32, color: Colors.blueGrey[300]),
        Container(
          width: 256,
          height: STARTUP_BUTTON_HEIGHT,
          color: Colors.blueGrey[200],
        ),
      ],
    );
  }

  Widget _errorState() {
    return Column(children: [Text("Hubo un error")]);
  }
}
