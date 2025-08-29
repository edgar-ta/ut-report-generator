import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/selection_mode.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/tabbed_menu.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/filter_component.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/copy_with_replacement.dart';
import 'package:ut_report_generator/utils/copy_without.dart';

class TestingComponent extends StatefulWidget {
  const TestingComponent({super.key});

  @override
  State<TestingComponent> createState() => _TestingComponentState();
}

class _TestingComponentState extends State<TestingComponent> {
  List<DataFilter> filters = [
    DataFilter(
      level: PivotTableLevel.group,
      selectedValues: ["Primero", "Segundo"],
      possibleValues: ["Primero", "Segundo", "Tercero"],
      selectionMode: SelectionMode.one,
      chartingMode: ChartingMode.none,
    ),
    DataFilter(
      level: PivotTableLevel.professor,
      selectedValues: ["Profesor A"],
      possibleValues: ["Profesor A", "Profesor B", "Profesor C"],
      selectionMode: SelectionMode.one,
      chartingMode: ChartingMode.chart,
    ),
    DataFilter(
      level: PivotTableLevel.subject,
      selectedValues: ["Matemáticas", "Historia"],
      possibleValues: ["Matemáticas", "Historia", "Biología"],
      selectionMode: SelectionMode.many,
      chartingMode: ChartingMode.superChart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SlideFrame(
      child: Container(color: Colors.blue),
      menuWidth: 512,
      menuContent: TabbedMenu(
        editTabBuilder: (context) {
          return ReorderableListView(
            buildDefaultDragHandles: false,
            children: [
              for (var index = 0; index < filters.length; index++)
                FilterComponent(
                  key: ValueKey(filters[index].level),
                  index: index,
                  filter: filters[index],
                  onChartingModeClicked: () {
                    setState(() {
                      filters =
                          filters.indexed.map((data) {
                            final (innerIndex, filter) = data;
                            return innerIndex == index
                                ? filter.copyWith(
                                  chartingMode: ChartingMode.chart,
                                )
                                : filter.copyWith(
                                  chartingMode: ChartingMode.none,
                                );
                          }).toList();
                    });
                  },
                  toggleSelectionMode: () {
                    setState(() {
                      filters = copyWithReplacement(
                        filters,
                        index,
                        (filter) => filter.copyWith(
                          selectionMode:
                              filter.selectionMode == SelectionMode.one
                                  ? SelectionMode.many
                                  : SelectionMode.one,
                        ),
                      );
                    });
                  },
                  selectAsMany: (value) async {
                    setState(() {
                      filters = copyWithReplacement(
                        filters,
                        index,
                        (filter) => filter.copyWith(
                          selectedValues: copyWithAdded(
                            filter.selectedValues,
                            value,
                          ),
                        ),
                      );
                    });
                  },
                  selectAsOne: (value) async {
                    setState(() {
                      filters[index] = filters[index].copyWith(
                        selectedValues: [value],
                      );
                    });
                  },
                  deselectAsMany: (value) async {
                    setState(() {
                      filters[index] = filters[index].copyWith(
                        selectedValues:
                            filters[index].selectedValues.length == 1
                                ? filters[index].selectedValues
                                : copyWithout(
                                  filters[index].selectedValues,
                                  value,
                                ),
                      );
                    });
                  },
                  onDelete: () async {
                    setState(() {
                      filters.removeAt(index);
                    });
                  },
                ),
            ],
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              setState(() {
                var element = filters.removeAt(oldIndex);
                filters.insert(newIndex, element);
              });
            },
          );
        },
        metadataTabBuilder: (context) {
          return Placeholder();
        },
      ),
    );
  }
}
