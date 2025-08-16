import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/api/hello.dart';
import 'package:ut_report_generator/api/recent_reports.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/error_page.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/loading_page.dart';
import 'package:ut_report_generator/home/recent_reports/widget.dart';
import 'package:ut_report_generator/home/report-editor/report_section/pick_file_button.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/widget.dart';
import 'package:ut_report_generator/home/file_picker_button.dart';
import 'package:ut_report_generator/home/report-editor/_main.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FullscreenLoadingOverlay(
      callback: helloRequest,
      errorScreen: ErrorPage(),
      loadingScreen: LoadingPage(
        messages: [
          "Conectando con el servidor",
          "Abriendo la base de datos",
          "Pensando",
          "Preguntándole a ChatGPT",
          "Calentando motores",
        ],
        title: "Conectando con el servidor",
      ),
      builder:
          (HelloRequest_Response helloRequestResponse) => Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Text(
                      helloRequestResponse!.message,
                      style: TextStyle(fontSize: 32),
                    ),
                    FilePickerButton(
                      onFilesPicked: (files) async {
                        context.go(
                          "/home/report-editor",
                          extra:
                              () async => await startReport(
                                files
                                    .map((file) => file.absolute.path)
                                    .toList(),
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              RecentReports(),
            ],
          ),
    );
  }
}
