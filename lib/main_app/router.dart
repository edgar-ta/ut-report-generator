import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/api/types/profile_record.dart';
import 'package:ut_report_generator/api/types/report_class.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/pages/bug-report/_main.dart';
import 'package:ut_report_generator/pages/home/_main.dart';
import 'package:ut_report_generator/pages/home/report-editor/_main.dart';
import 'package:ut_report_generator/main_app/route_observer.dart';
import 'package:ut_report_generator/pages/profile/_main.dart';
import 'package:ut_report_generator/testing_components/chart_screen.dart';
import 'package:ut_report_generator/testing_components/chips_tile.dart';
import 'package:ut_report_generator/testing_components/dropdown_menus_tile.dart';
import 'package:ut_report_generator/testing_components/slide_frame.dart';
import 'package:ut_report_generator/utils/control_variables.dart';

final router = GoRouter(
  initialLocation: IS_DEVELOPMENT_MODE && IS_TESTING_MODE ? "/test" : "/home",
  observers: [routeObserver],
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(child: navigationShell);
      },
      branches: [
        if (IS_DEVELOPMENT_MODE && IS_TESTING_MODE)
          (StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/test',
                builder: (context, state) {
                  return ChartScreen();
                },
              ),
            ],
          )),
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
              path: '/profile',
              builder:
                  (context, state) => ProfilePage(
                    initialProfile: ProfileRecord(
                      name: "Edgar Trejo Avila",
                      type: UserType.professor,
                      gender: UserGender.masculine,
                    ),
                  ),
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
      ],
    ),
  ],
);
