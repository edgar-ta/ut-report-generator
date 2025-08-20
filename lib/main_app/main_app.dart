import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/models/asset_class.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/models/report_class.dart';
import 'package:ut_report_generator/models/slide_class.dart';
import 'package:ut_report_generator/models/slide_type.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/pages/home/_main.dart';
import 'package:ut_report_generator/pages/home/report-editor/_main.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/main_app/router.dart';

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScaffoldController(),
      child: MaterialApp.router(
        title: "Generador de Reportes de la UTSJR",
        routerConfig: router,
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(
        //     seedColor: Color(0xFF002855),
        //     primaryContainer: Color(0xFF009966),
        //     onPrimaryContainer: Colors.white,
        //     tertiaryContainer: Color.fromARGB(255, 170, 250, 223),
        //     onTertiaryContainer: const Color.fromARGB(255, 0, 0, 0),
        //     surface: Color.fromARGB(255, 250, 250, 250),
        //     onSurface: const Color.fromARGB(255, 78, 78, 78),
        //     surfaceContainer: const Color.fromARGB(255, 245, 245, 245),
        //     surfaceContainerHigh: const Color.fromARGB(255, 195, 211, 226),
        //     outline: const Color.fromARGB(255, 33, 137, 255),
        //   ),
        // ),
      ),
    );

    return ReportEditor(
      reportCallback:
          () => Future(
            () => StartReport_Response(
              reportDirectory:
                  r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\python-app\reports\ce4efb78-60bf-4745-8015-ec1dd3aa3d04",
              reportName: "Mi reporte",
              creationDate: DateTime.now(),
              slides: [
                SlideClass(
                  id: "5601ae90-7b60-4ff0-ae71-5855408a3427",
                  key: '5601ae90-7b60-4ff0-ae71-5855408a3427',
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
                  dataFiles: [
                    "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\.logistics-assets\\example-data.xls",
                  ],
                  preview:
                      "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\python-app\\reports\\e706722b-7d8b-4d24-92c8-97f16e3f5470\\slides\\78173aaf-780c-41d7-95cd-bace3038263e\\preview.png",
                ),
              ],
              renderedFile:
                  "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\python-app\\reports\\e706722b-7d8b-4d24-92c8-97f16e3f5470\\Mi reporte.pptx",
            ),
          ),
    );
  }
}
