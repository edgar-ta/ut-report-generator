import 'package:flutter/material.dart';
import 'package:ut_report_generator/components/home/home_page_header/state.dart';
import 'package:ut_report_generator/utils/future_status.dart';

class HomePageHeader extends StatelessWidget {
  final HomePageHeaderState state;
  const HomePageHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == FutureStatus.pending) {
      return Text("Cargando");
    }
    return Text(state.response!.message, style: TextStyle(fontSize: 32));
  }
}
