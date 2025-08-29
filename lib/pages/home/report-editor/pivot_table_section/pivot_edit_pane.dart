import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/components/invisible_text_field.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/filter_component.dart';

class PivotEditPane extends StatefulWidget {
  final TextEditingController nameController;
  final List<DataFilter> filters;

  final Future<void> Function(String file) onFileRemoved;
  final Future<void> Function(String file) onFileAdded;

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
    return Column(
      children: [
        InvisibleTextField(controller: widget.nameController),
        SegmentedButton(
          segments: [
            ButtonSegment(value: "a", icon: Icon(Icons.bar_chart)),
            ButtonSegment(value: "b", icon: Icon(Icons.image)),
          ],
          selected: {"a"},
        ),
        ReorderableListView(
          shrinkWrap: true,
          onReorder: (oldIndex, newIndex) {
            widget.onFiltersReordered(oldIndex, newIndex);
          },
          children:
              widget.filters.indexed.map((data) {
                final (index, filter) = data;
                return FilterComponent(
                  index: index,
                  filter: filter,
                  onChartingModeClicked: () async {
                    // There must always be a chart mode filter

                    if (HardwareKeyboard.instance.isControlPressed) {
                      if (filter.chartingMode == ChartingMode.superChart) {
                        widget.unsetSuperChart();
                        return;
                      }
                      if (filter.chartingMode == ChartingMode.none) {
                        widget.setSuperChart(index);
                        return;
                      }

                      final superChartFilterIndex = widget.filters.indexWhere(
                        (element) =>
                            element.chartingMode == ChartingMode.superChart,
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
    );
  }
}
