import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/components/invisible_text_field.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/selection_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/filter_component.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/filter_selector.dart';
import 'package:ut_report_generator/api/pivot_table/filter/self.dart'
    as filter_api;
import 'package:ut_report_generator/utils/copy_with_added.dart';

class PivotEditPane extends StatefulWidget {
  final String report;
  final PivotTable pivotTable;
  final void Function(PivotTable Function(PivotTable)) setPivotTable;

  final TextEditingController nameController;
  final List<DataFilter> filters;

  final Future<void> Function(String option, int filterIndex) onOptionAdded;
  final Future<void> Function(String option, int filterIndex) onOptionSwitched;
  final Future<void> Function(String option, int filterIndex) onOptionRemoved;
  final Future<void> Function(int filterIndex) onFilterDeleted;
  final Future<void> Function(int filterIndex) toggleSelectionMode;
  final Future<void> Function(int firstFilter, int secondFilter)
  swapChartingModes;
  final Future<void> Function(int filterIndex) setChart;
  final Future<void> Function(int filterIndex) setSuperChart;
  final Future<void> Function() unsetSuperChart;
  final Future<void> Function(int newIndex, int oldIndex) onFiltersReordered;

  PivotEditPane({
    super.key,
    required this.report,
    required this.pivotTable,
    required this.setPivotTable,
    required this.nameController,
    required this.filters,
    required this.onOptionAdded,
    required this.onOptionRemoved,
    required this.onOptionSwitched,
    required this.onFilterDeleted,
    required this.onFiltersReordered,
    required this.toggleSelectionMode,
    required this.swapChartingModes,
    required this.setChart,
    required this.setSuperChart,
    required this.unsetSuperChart,
  });

  @override
  State<PivotEditPane> createState() => _PivotEditPaneState();
}

class _PivotEditPaneState extends State<PivotEditPane> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InvisibleTextField(controller: widget.nameController),
          FilterSelector(
            title: "Filtros",
            availableFilters:
                PivotTableLevel.values
                    .where(
                      (level) =>
                          !widget.filters
                              .map((filter) => filter.level)
                              .contains(level),
                    )
                    .toList(),
            onFilterSelected: (level) {
              widget.setPivotTable(
                (pivotTable) => pivotTable.copyWith(
                  filters: copyWithAdded(
                    pivotTable.filters,
                    DataFilter(
                      level: level,
                      selectedValues: [],
                      possibleValues: [],
                      // This has to match the default mode in the backend
                      // in order to improve UI consistency
                      selectionMode: SelectionMode.many,
                      chartingMode: ChartingMode.none,
                    ),
                  ),
                ),
              );
              filter_api
                  .createDataFilter(
                    report: widget.report,
                    pivotTable: widget.pivotTable.identifier,
                    level: level,
                  )
                  .then((newFilter) {
                    widget.setPivotTable(
                      (pivotTable) => pivotTable.copyWith(
                        filters:
                            pivotTable.filters
                                .map(
                                  (filter) =>
                                      filter.level == level
                                          ? newFilter
                                          : filter,
                                )
                                .toList(),
                      ),
                    );
                  });
            },
          ),
          ReorderableListView(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) {
              widget.onFiltersReordered(oldIndex, newIndex);
            },
            children:
                widget.filters.indexed.map((data) {
                  final (index, filter) = data;
                  return FilterComponent(
                    key: ValueKey(filter.level),
                    index: index,
                    filter: filter,
                    onChartingModeClicked: () async {
                      // There must always be a chart mode filter

                      if (HardwareKeyboard.instance.isControlPressed) {
                        if (filter.chartingMode == ChartingMode.superChart) {
                          await widget.unsetSuperChart();
                          return;
                        }
                        if (filter.chartingMode == ChartingMode.none) {
                          await widget.setSuperChart(index);
                          return;
                        }

                        final superChartFilterIndex = widget.filters.indexWhere(
                          (element) =>
                              element.chartingMode == ChartingMode.superChart,
                        );
                        await widget.swapChartingModes(
                          index,
                          superChartFilterIndex,
                        );
                      } else {
                        if (filter.chartingMode == ChartingMode.none) {
                          await widget.setChart(index);
                        }
                      }
                    },
                    toggleSelectionMode: () async {
                      widget.toggleSelectionMode(index);
                    },
                    selectAsOne: (value) async {
                      widget.onOptionSwitched(value, index);
                    },
                    selectAsMany: (value) async {
                      widget.onOptionAdded(value, index);
                    },
                    deselectAsMany: (value) async {
                      widget.onOptionRemoved(value, index);
                    },
                    onDelete: () async {
                      widget.onFilterDeleted(index);
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
