import 'package:go_router/go_router.dart';
import 'package:ut_report_generator/models/profile.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/components/util/app_scaffold.dart';
import 'package:ut_report_generator/models/slideshow_editor_request.dart';
import 'package:ut_report_generator/pages/bug_report_page.dart';
import 'package:ut_report_generator/pages/home/page.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/page.dart';
import 'package:ut_report_generator/main_app/route_observer.dart';
import 'package:ut_report_generator/pages/profile_page.dart';
import 'package:ut_report_generator/testing_components/testing_component.dart';
import 'package:ut_report_generator/utils/control_variables.dart';

final router = GoRouter(
  initialLocation: isTestingDuringDevelopment() ? "/test" : "/home",
  observers: [routeObserver],
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(child: navigationShell);
      },
      branches: [
        if (isTestingDuringDevelopment())
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
                  path: 'slideshow_editor',
                  builder: (context, state) {
                    final extra = state.extra as SlideshowEditorRequest;
                    return SlideshowEditor(
                      slideshowCallback: extra.startCallback,
                      callbackWhenReturning: extra.callbackWhenReturning,
                    );
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
