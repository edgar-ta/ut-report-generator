import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/api/types/report_class.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/api/types/slide_type.dart';
import 'package:ut_report_generator/bugs/_main.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/home/_main.dart';
import 'package:ut_report_generator/home/report-editor/_main.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/profile/_main.dart';
import 'package:ut_report_generator/scaffold_controller.dart';

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _router = GoRouter(
    initialLocation: "/home",
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => HomePage(),
                routes: [
                  GoRoute(
                    path: 'report-editor',
                    builder: (context, state) {
                      final reportCallback =
                          state.extra as Future<ReportClass> Function();
                      return ReportEditor(reportCallback: reportCallback);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bug-report',
                builder: (context, state) => BugReportPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScaffoldController(),
      child: MaterialApp.router(routerConfig: _router),
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
