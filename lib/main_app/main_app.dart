import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/api/report/start_report_with_pivot_table.dart';
import 'package:ut_report_generator/main.dart';
import 'package:ut_report_generator/models/report.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/pages/home/_main.dart';
import 'package:ut_report_generator/pages/home/report-editor/_main.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/main_app/router.dart';
import 'package:ut_report_generator/utils/control_variables.dart';

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScaffoldController(),
      child: MaterialApp.router(title: appTitle(), routerConfig: router),
    );
  }
}
