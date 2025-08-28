import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/filter_component.dart';

class PivotEditPane extends StatefulWidget {
  final TextEditingController nameController;
  final List<DataFilter> filters;

  final Future<void> Function(String file) onFileRemoved;
  final Future<void> Function(String file) onFileAdded;

  final Future<void> Function(String option, PivotTableLevel level)
  onOptionAdded;
  final Future<void> Function(String option, PivotTableLevel level)
  onOptionSwitched;
  final Future<void> Function(String option, PivotTableLevel level)
  onOptionRemoved;

  final Future<void> Function(int filter) onFilterDeleted;

  final Future<void> Function(int filter) toggleSelectionMode;

  final Future<void> Function(int firstFilter, int secondFilter)
  swapChartingModes;
  final Future<void> Function(int filter) setChart;
  final Future<void> Function(int filter) setSuperChart;
  final Future<void> Function(int filter) unsetSuperChart;

  final Future<void> Function(int newIndex, int oldIndex) onFiltersReordered;

  const PivotEditPane({
    super.key,
    required this.nameController,
    required this.filters,
    required this.onFileRemoved,
    required this.onFileAdded,
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
    return ReorderableList(
      itemBuilder: (context, index) {
        final filter = widget.filters[index];
        return FilterComponent(
          index: index,
          filter: filter,
          onChartingModeClicked: () async {
            // There must always be a chart mode filter

            if (HardwareKeyboard.instance.isControlPressed) {
              if (filter.chartingMode == ChartingMode.superChart) {
                widget.unsetSuperChart(index);
                return;
              }
              if (filter.chartingMode == ChartingMode.none) {
                widget.setSuperChart(index);
                return;
              }

              final superChartFilterIndex = widget.filters.indexWhere(
                (element) => element.chartingMode == ChartingMode.superChart,
              );
              widget.swapChartingModes(index, superChartFilterIndex);
              return;
            } else {
              if (filter.chartingMode == ChartingMode.none) {
                widget.setChart(index);
                return;
              }
            }
          },
          toggleSelectionMode: () async {
            widget.toggleSelectionMode(index);
          },
          selectAsOne: (value) async {
            widget.onOptionSwitched(value, filter.level);
          },
          selectAsMany: (value) async {
            widget.onOptionAdded(value, filter.level);
          },
          deselectAsMany: (value) async {
            widget.onOptionRemoved(value, filter.level);
          },
          onDelete: () async {
            widget.onFilterDeleted(index);
          },
        );
      },
      itemCount: widget.filters.length,
      onReorder: (oldIndex, newIndex) {
        widget.onFiltersReordered(oldIndex, newIndex);
      },
    );
  }
}
