import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ut_report_generator/main_app/main_app_wrapper.dart';
import 'package:ut_report_generator/utils/control_variables.dart';
import 'package:ut_report_generator/main_app/main_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();

  if (isDevelopmentMode()) {
    if (isTestingMode()) {
      debugPaintPointersEnabled = true;
    }
    runApp(MainApp());
  } else {
    runApp(MainAppWrapper());
  }
}
