import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/api/types/slide_type.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/home/_main.dart';
import 'package:ut_report_generator/home/report-editor/_main.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return AppScaffold(verifyConnection: true);
    return ReportEditor(
      initialReport: StartReport_Response(
        reportDirectory:
            r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\python-app\reports\ce4efb78-60bf-4745-8015-ec1dd3aa3d04",
        reportName: "Mi reporte",
        slides: [
          SlideClass(
            id: "5601ae90-7b60-4ff0-ae71-5855408a3427",
            type: SlideType.failureRate,
            assets: [
              AssetClass(
                name: "main-chart",
                value:
                    r"D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\python-app\\reports\\ce4efb78-60bf-4745-8015-ec1dd3aa3d04\\images\\688f24b8-720b-4676-8044-b82b2ddc5aa3.png",
                type: "image",
              ),
            ],
            arguments: {"unit": 1, "show_delayed_teachers": true},
            dataFile:
                "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\.logistics-assets\\example-data--xd.xls",
            preview:
                "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\python-app\\reports\\ce4efb78-60bf-4745-8015-ec1dd3aa3d04\\images\\2b0d554e-f84f-4699-9d3d-86907eed7fec.png",
          ),
        ],
      ),
    );
  }
}
