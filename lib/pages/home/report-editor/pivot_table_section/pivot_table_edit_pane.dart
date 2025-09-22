import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/blocs/pivot_table_bloc.dart';
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

class PivotTableEditPane extends StatefulWidget {
  final PivotTableBloc bloc;
  final String title;
  final List<DataFilter> filters;

  PivotTableEditPane({
    super.key,
    required this.title,
    required this.bloc,
    required this.filters,
  });

  @override
  State<PivotTableEditPane> createState() => _PivotTableEditPaneState();
}

class _PivotTableEditPaneState extends State<PivotTableEditPane> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InvisibleTextField(
              controller: TextEditingController(text: widget.title),
            ),
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
                widget.bloc.onFilterSelected(level);
              },
            ),
            ReorderableListView(
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                widget.bloc.onFiltersReordered(oldIndex, newIndex);
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
                            await widget.bloc.unsetSuperChart();
                            return;
                          }
                          if (filter.chartingMode == ChartingMode.none) {
                            await widget.bloc.setSuperChart(index);
                            return;
                          }

                          final superChartFilterIndex = widget.filters
                              .indexWhere(
                                (element) =>
                                    element.chartingMode ==
                                    ChartingMode.superChart,
                              );
                          await widget.bloc.swapChartingModes(
                            index,
                            superChartFilterIndex,
                          );
                        } else {
                          if (filter.chartingMode == ChartingMode.none) {
                            await widget.bloc.setChart(index);
                          }
                        }
                      },
                      toggleSelectionMode: () async {
                        widget.bloc.toggleSelectionMode(index);
                      },
                      selectAsOne: (value) async {
                        widget.bloc.onOptionSwitched(value, index);
                      },
                      selectAsMany: (value) async {
                        widget.bloc.onOptionAdded(value, index);
                      },
                      deselectAsMany: (value) async {
                        widget.bloc.onOptionRemoved(value, index);
                      },
                      onDelete: () async {
                        widget.bloc.onFilterDeleted(index);
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
