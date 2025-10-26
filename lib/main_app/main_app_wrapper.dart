import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/main_app/main_app.dart';
import 'package:ut_report_generator/utils/start_server.dart';

class MainAppWrapper extends StatefulWidget {
  final Process pythonServer;

  const MainAppWrapper({super.key, required this.pythonServer});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  late final AppLifecycleListener listener;

  @override
  void initState() {
    super.initState();
    listener = AppLifecycleListener(
      onExitRequested: () async {
        widget.pythonServer.kill();
        return AppExitResponse.exit;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainApp();
  }
}
