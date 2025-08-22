import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/api/report/start_report_with_pivot_table.dart';
import 'package:ut_report_generator/models/report.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
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
              identifier:
                  r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\python-app\reports\ce4efb78-60bf-4745-8015-ec1dd3aa3d04",
              reportName: "Mi reporte",
              creationDate: DateTime.now(),
              slides: [
                ImageSlide(
                  identifier: "5601ae90-7b60-4ff0-ae71-5855408a3427",
                  kind: ImageSlideKind.coverPage,
                  arguments: {"unit": 1, "show_delayed_teachers": true},
                  preview:
                      "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\python-app\\reports\\e706722b-7d8b-4d24-92c8-97f16e3f5470\\slides\\78173aaf-780c-41d7-95cd-bace3038263e\\preview.png",
                ),
              ],
            ),
          ),
    );
  }
}
