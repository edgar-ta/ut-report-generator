import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/models/profile.dart';
import 'package:ut_report_generator/models/report.dart';
import 'package:ut_report_generator/components/app_scaffold.dart';
import 'package:ut_report_generator/pages/bug-report/_main.dart';
import 'package:ut_report_generator/pages/home/_main.dart';
import 'package:ut_report_generator/pages/home/report-editor/_main.dart';
import 'package:ut_report_generator/main_app/route_observer.dart';
import 'package:ut_report_generator/pages/profile/_main.dart';
import 'package:ut_report_generator/testing_components/testing_component.dart';
import 'package:ut_report_generator/utils/control_variables.dart';

final router = GoRouter(
  initialLocation: isDevelopmentMode() && isTestingMode() ? "/test" : "/home",
  observers: [routeObserver],
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(child: navigationShell);
      },
      branches: [
        if (isDevelopmentMode() && isTestingMode())
          (StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/test',
                builder: (context, state) {
                  return TestingComponent();
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
