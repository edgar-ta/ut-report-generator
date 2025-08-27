import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';

class FilterComponent extends StatefulWidget {
  final void Function() changeChartingMode;
  final void Function() toggleSelectionMode;
  final Future<void> Function(String) selectAsOne;
  final Future<void> Function(String) selectAsMany;
  final Future<void> Function(String) deselectAsMany;
  final Future<void> Function() onDelete;

  final int index;
  final FilterRecord filterRecord;

  const FilterComponent({
    super.key,
    required this.index,
    required this.filterRecord,
    required this.changeChartingMode,
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
                                    widget.filterRecord.chartingMode !=
                                        ChartingMode.none)
                                ? 1
                                : 0,
                        duration: Duration(milliseconds: 200),
                        child: IconButton(
                          onPressed: widget.changeChartingMode,
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
                            widget.filterRecord.selectionMode ==
                                    SelectionMode.one
                                ? "Seleccionar uno"
                                : "Seleccionar muchos",
                        onPressed: widget.toggleSelectionMode,
                        icon:
                            widget.filterRecord.selectionMode ==
                                    SelectionMode.one
                                ? Icon(Icons.filter_1)
                                : Icon(Icons.view_module),
                      ),
                      Expanded(
                        child:
                            widget.filterRecord.selectionMode ==
                                    SelectionMode.one
                                ? (DropdownMenu(
                                  inputDecorationTheme: InputDecorationTheme(
                                    border: InputBorder.none,
                                  ),
                                  initialSelection:
                                      widget.filterRecord.selectedValues[0],
                                  dropdownMenuEntries:
                                      widget.filterRecord.possibleValues
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
                      widget.filterRecord.selectionMode == SelectionMode.many
                          ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                widget.filterRecord.possibleValues
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
                                        selected: widget
                                            .filterRecord
                                            .selectedValues
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
    switch (widget.filterRecord.chartingMode) {
      case ChartingMode.none:
        return Icon(Icons.visibility_off);
      case ChartingMode.chart:
        return Icon(Icons.visibility);
      case ChartingMode.superChart:
        return Icon(Icons.bar_chart);
    }
  }

  String _labelOfLevel() {
    switch (widget.filterRecord.level) {
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
    final values = widget.filterRecord.selectedValues;

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
