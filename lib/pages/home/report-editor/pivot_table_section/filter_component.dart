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
  bool _areChipsShown = false;

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
      child: AnimatedContainer(
        color: widget.filter.isValid() ? Colors.white : Colors.grey[100],
        duration: Duration(milliseconds: 200),
        child: AnimatedOpacity(
          opacity: widget.filter.isValid() ? 1 : 0.5,
          duration: Duration(milliseconds: 200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DragHandle(
                isHovered: _isHovered,
                index: widget.index,
                height: rowHeight,
              ),
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
                                ((widget.filter.isValid() && _isHovered) ||
                                        widget.filter.chartingMode !=
                                            ChartingMode.none)
                                    ? 1
                                    : 0,
                            duration: Duration(milliseconds: 200),
                            child: IconButton(
                              onPressed:
                                  widget.filter.isValid()
                                      ? widget.onChartingModeClicked
                                      : null,
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
                          // Botón para cambiar modo de selección
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: _isHovered ? 64 : 0,
                            height: 64,
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 200),
                              opacity: _isHovered ? 1 : 0,
                              child: _selectionModeButton(),
                            ),
                          ),
                          Expanded(child: _selectionModeLabel()),
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
                          (widget.filter.selectionMode == SelectionMode.many &&
                                  _areChipsShown)
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
                                                await widget.selectAsMany(
                                                  value,
                                                );
                                              } else {
                                                await widget.deselectAsMany(
                                                  value,
                                                );
                                              }
                                            },
                                            selected: widget
                                                .filter
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
        ),
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
    const int wordThreshold = 10; // umbral para truncar cada string
    const int combinedThreshold =
        20; // umbral para longitud combinada de los dos primeros

    final mappedValues =
        values.map((v) {
          if (v.length > wordThreshold) {
            final firstWord = v.split(' ').first;
            return firstWord;
          }
          return v;
        }).toList();

    if (mappedValues.isEmpty) return "";
    if (mappedValues.length == 1) return mappedValues.first;
    if (mappedValues.length == 2) {
      return "${mappedValues[0]} y ${mappedValues[1]}";
    }

    final first = mappedValues[0];
    final second = mappedValues[1];
    final combinedLength = first.length + second.length;

    if (combinedLength > combinedThreshold) {
      final remainingCount = mappedValues.length - 1;
      return "$first y $remainingCount más";
    }

    if (mappedValues.length == 3) {
      return "$first, $second y ${mappedValues[2]}";
    }

    final remainingCount = mappedValues.length - 2;
    return "$first, $second y $remainingCount más";
  }

  Widget _selectionModeLabel() {
    if (!widget.filter.isValid()) {
      return Text("Sin valores posibles", style: TextStyle(fontSize: 16));
    }

    if (widget.filter.selectionMode == SelectionMode.one) {
      return DropdownMenu(
        inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
        controller: TextEditingController(
          text:
              widget.filter.selectedValues.isNotEmpty
                  ? widget.filter.selectedValues[0]
                  : "...",
        ),
        initialSelection:
            widget.filter.selectedValues.isNotEmpty
                ? widget.filter.selectedValues[0]
                : null,
        dropdownMenuEntries:
            widget.filter.possibleValues
                .map((value) => DropdownMenuEntry(value: value, label: value))
                .toList(),
        onSelected: (value) async {
          if (value != null) {
            widget.selectAsOne(value);
          }
        },
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            _labelOfSelectedValues(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _areChipsShown = !_areChipsShown;
            });
          },
          icon: Icon(
            _areChipsShown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          ),
        ),
      ],
    );
  }

  Widget _selectionModeButton() {
    if (!widget.filter.isValid()) {
      return IconButton(onPressed: null, icon: Icon(Icons.error));
    }

    if (widget.filter.selectionMode == SelectionMode.one) {
      return IconButton(
        onPressed: () async {
          widget.toggleSelectionMode();
          setState(() {
            _areChipsShown = true;
          });
        },
        icon: Icon(Icons.view_module),
        tooltip: "Ver muchos",
      );
    }
    return IconButton(
      onPressed: widget.toggleSelectionMode,
      icon: Icon(Icons.filter_1),
      tooltip: "Ver uno",
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({
    super.key,
    required this.isHovered,
    required this.index,
    required this.height,
  });

  final bool isHovered;
  final int index;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isHovered ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !isHovered,
        child: ReorderableDragStartListener(
          index: index,
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
