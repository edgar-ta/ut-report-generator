import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/selection_mode.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';

class FilterComponent extends StatefulWidget {
  final void Function() onChartingModeClicked;
  final void Function() toggleSelectionMode;
  final Future<void> Function(String) selectAsOne;
  final Future<void> Function(String) selectAsMany;
  final Future<void> Function(String) deselectAsMany;
  final Future<void> Function() onDelete;

  final int index;
  final DataFilter filter;

  const FilterComponent({
    super.key,
    required this.index,
    required this.filter,
    required this.onChartingModeClicked,
    required this.toggleSelectionMode,
    required this.selectAsOne,
    required this.selectAsMany,
    required this.deselectAsMany,
    required this.onDelete,
  });

  @override
  State<FilterComponent> createState() => _FilterComponentState();
}

class _FilterComponentState extends State<FilterComponent> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double rowHeight = 48;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DragHandle(isHovered: _isHovered, widget: widget, height: rowHeight),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: rowHeight,
                  child: Row(
                    spacing: 8,
                    children: [
                      AnimatedOpacity(
                        opacity:
                            (_isHovered ||
                                    widget.filter.chartingMode !=
                                        ChartingMode.none)
                                ? 1
                                : 0,
                        duration: Duration(milliseconds: 200),
                        child: IconButton(
                          onPressed: widget.onChartingModeClicked,
                          icon: _visualizationModeIcon(),
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        child: Text(
                          _labelOfLevel(),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      VerticalDivider(width: 1),
                      IconButton(
                        tooltip:
                            widget.filter.selectionMode == SelectionMode.one
                                ? "Seleccionar uno"
                                : "Seleccionar muchos",
                        onPressed: widget.toggleSelectionMode,
                        icon:
                            widget.filter.selectionMode == SelectionMode.one
                                ? Icon(Icons.filter_1)
                                : Icon(Icons.view_module),
                      ),
                      Expanded(
                        child:
                            widget.filter.selectionMode == SelectionMode.one
                                ? (DropdownMenu(
                                  inputDecorationTheme: InputDecorationTheme(
                                    border: InputBorder.none,
                                  ),
                                  initialSelection:
                                      widget.filter.selectedValues[0],
                                  dropdownMenuEntries:
                                      widget.filter.possibleValues
                                          .map(
                                            (value) => DropdownMenuEntry(
                                              value: value,
                                              label: value,
                                            ),
                                          )
                                          .toList(),
                                  onSelected: (value) async {
                                    if (value != null) {
                                      widget.selectAsOne(value);
                                    }
                                  },
                                ))
                                : (Text(
                                  _labelOfSelectedValues(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 16),
                                )),
                      ),
                      AnimatedOpacity(
                        opacity: _isHovered ? 1 : 0,
                        duration: Duration(milliseconds: 200),
                        child: IconButton(
                          onPressed: widget.onDelete,
                          icon: Icon(Icons.delete),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child:
                      widget.filter.selectionMode == SelectionMode.many
                          ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                widget.filter.possibleValues
                                    .map(
                                      (value) => FilterChip(
                                        label: Text(value),
                                        onSelected: (selected) async {
                                          if (selected) {
                                            await widget.selectAsMany(value);
                                          } else {
                                            await widget.deselectAsMany(value);
                                          }
                                        },
                                        selected: widget.filter.selectedValues
                                            .contains(value),
                                      ),
                                    )
                                    .toList(),
                          )
                          : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _visualizationModeIcon() {
    switch (widget.filter.chartingMode) {
      case ChartingMode.none:
        return Icon(Icons.visibility_off);
      case ChartingMode.chart:
        return Icon(Icons.visibility);
      case ChartingMode.superChart:
        return Icon(Icons.bar_chart);
    }
  }

  String _labelOfLevel() {
    switch (widget.filter.level) {
      case PivotTableLevel.group:
        return "Grupo";
      case PivotTableLevel.professor:
        return "Profesor";
      case PivotTableLevel.subject:
        return "Materia";
      case PivotTableLevel.unit:
        return "Unidad";
      case PivotTableLevel.year:
        return "Año";
    }
  }

  String _labelOfSelectedValues() {
    final values = widget.filter.selectedValues;

    if (values.isEmpty) return "";
    if (values.length == 1) return values.first;

    final allButLast = values.sublist(0, values.length - 1).join(", ");
    final last = values.last;

    return "$allButLast y $last";
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({
    super.key,
    required bool isHovered,
    required this.widget,
    required this.height,
  }) : _isHovered = isHovered;

  final bool _isHovered;
  final FilterComponent widget;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isHovered ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !_isHovered,
        child: ReorderableDragStartListener(
          index: widget.index,
          child: InkWell(
            mouseCursor: SystemMouseCursors.move,
            child: Container(
              padding: EdgeInsets.all(8.0),
              height: height,
              child: Icon(Icons.drag_handle),
            ),
          ),
        ),
      ),
    );
  }
}
