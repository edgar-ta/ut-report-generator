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
                  var subjectsLists = [
                    ["Español", "Inglés", "Matemáticas"],
                    ["Biología", "Filosofía"],
                  ];
                  var keysList = ["a", "b"];
                  var titlesList = ["Materias básicas", "Materias avanzadas"];

                  var typesOfOptions = ["Profesor", "Materias"];
                  var optionsLists = [
                    ["Goyo", "Luzma", "René"],
                    ["POO", "Cálculo", "DSM"],
                  ];
                  var selectedPrimaryValues = ["Profesor", "Materias"];
                  var selectedSecondaryValues = ["Goyo", "POO"];

                  return SlideFrame(
                    menuWidth: 512,
                    menuContent: StatefulBuilder(
                      builder: (context, setInnerState) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 256,
                              child: ReorderableListView(
                                onReorder: (int oldIndex, int newIndex) {
                                  setInnerState(() {
                                    if (oldIndex + 1 < newIndex) {
                                      newIndex -= 1;
                                    }
                                    var removedOptionsList = optionsLists
                                        .removeAt(oldIndex);
                                    var removedPrimaryValue =
                                        selectedPrimaryValues.removeAt(
                                          oldIndex,
                                        );
                                    var removedSecondaryValue =
                                        selectedSecondaryValues.removeAt(
                                          oldIndex,
                                        );

                                    optionsLists.insert(
                                      newIndex,
                                      removedOptionsList,
                                    );
                                    selectedPrimaryValues.insert(
                                      newIndex,
                                      removedPrimaryValue,
                                    );
                                    selectedSecondaryValues.insert(
                                      newIndex,
                                      removedSecondaryValue,
                                    );
                                  });
                                },
                                buildDefaultDragHandles: false,
                                children: [
                                  for (var i = 0; i < optionsLists.length; i++)
                                    DropdownMenusTile(
                                      key: ValueKey(selectedPrimaryValues[i]),
                                      title: selectedPrimaryValues[i],
                                      primaryItems: typesOfOptions,
                                      secondaryItems: optionsLists[i],
                                      selectedPrimary: selectedPrimaryValues[i],
                                      selectedSecondary:
                                          selectedSecondaryValues[i],
                                      primaryItemBuilder:
                                          (context, value) => Text(value),
                                      secondaryItemBuilder:
                                          (context, value) => Text(value),
                                      onPrimaryChanged: (value) {},
                                      onSecondaryChanged: (value) {
                                        setInnerState(() {
                                          selectedSecondaryValues[i] = value;
                                        });
                                      },
                                      index: i,
                                      onDelete: () {
                                        setInnerState(() {
                                          optionsLists.removeAt(i);
                                          selectedPrimaryValues.removeAt(i);
                                          selectedSecondaryValues.removeAt(i);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 256,
                              child: ReorderableListView(
                                onReorder: (int oldIndex, int newIndex) {
                                  setInnerState(() {
                                    if (oldIndex + 1 < newIndex) {
                                      newIndex -= 1;
                                    }
                                    var removedSubjectsList = subjectsLists
                                        .removeAt(oldIndex);
                                    var removedKey = keysList.removeAt(
                                      oldIndex,
                                    );
                                    var removedTitle = titlesList.removeAt(
                                      oldIndex,
                                    );

                                    subjectsLists.insert(
                                      newIndex,
                                      removedSubjectsList,
                                    );
                                    keysList.insert(newIndex, removedKey);
                                    titlesList.insert(newIndex, removedTitle);
                                  });
                                },
                                buildDefaultDragHandles: false,
                                children: [
                                  for (var i = 0; i < subjectsLists.length; i++)
                                    ChipsTile(
                                      index: i,
                                      key: ValueKey(keysList[i]),
                                      title: titlesList[i],
                                      entries:
                                          subjectsLists[i]
                                              .map(
                                                (subject) => ChipsTileEntry(
                                                  key: ValueKey(subject),
                                                  value: subject,
                                                  selected: true,
                                                ),
                                              )
                                              .toList(),
                                      onDelete: () {
                                        setInnerState(() {
                                          subjectsLists.removeAt(i);
                                          keysList.removeAt(i);
                                          titlesList.removeAt(i);
                                        });
                                      },
                                      chipBuilder: (context, value, selected) {
                                        return FilterChip(
                                          label: Text(value),
                                          onSelected: (isSelected) {},
                                          selected: selected,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    child: Text("Hello world"),
                  );
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
