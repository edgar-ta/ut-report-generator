import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/home/_main.dart';
import 'package:ut_report_generator/home/report-editor/_main.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(verifyConnection: true);
    return ReportEditor(
      response: StartReport_Response(
        reportDirectory: "8fe5d3ef-804c-4be3-a88b-c16c3139de6d",
        reportName: "Mi reporte",
        assets: [
          (
            name: "main-chart",
            value:
                r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\python-app\reports\8fe5d3ef-804c-4be3-a88b-c16c3139de6d\images\c5f52263-cd31-4429-93b8-c2f03ba33f22.png",
            type: "image",
          ),
        ],
        slideId: "cd6f1a07-455f-4c90-acf0-93bacd3d10df",
        arguments: {"unit": "1", "show_delayed_teachers": "true"},
        preview:
            "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\python-app\\reports\\8fe5d3ef-804c-4be3-a88b-c16c3139de6d\\images\\cd6f1a07-455f-4c90-acf0-93bacd3d10df.png",
      ),
    );
  }
}
