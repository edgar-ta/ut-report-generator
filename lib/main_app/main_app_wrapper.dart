import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/main_app/main_app.dart';
import 'package:ut_report_generator/utils/start_server.dart';

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  late Future<Process> pythonServer;
  late final AppLifecycleListener listener;

  @override
  void initState() {
    super.initState();
    pythonServer = startServer();
    listener = AppLifecycleListener(
      onExitRequested: () async {
        await pythonServer.then((process) {
          process.kill();
        });
        return AppExitResponse.exit;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainApp();
  }
}
