import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';

class FilterSelector extends StatefulWidget {
  final List<PivotTableLevel> availableFilters;
  final void Function(PivotTableLevel) onFilterSelected;
  final String title;

  const FilterSelector({
    super.key,
    required this.availableFilters,
    required this.onFilterSelected,
    required this.title,
  });

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.title);
    controller.addListener(() {
      if (controller.text != widget.title) {
        controller.text = widget.title;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      controller: controller,
      initialSelection: null,
      trailingIcon: Icon(Icons.add),
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      enableSearch: false,
      dropdownMenuEntries:
          widget.availableFilters
              .map(
                (filter) => DropdownMenuEntry(
                  value: filter.name,
                  label: levelToSpanish(filter),
                ),
              )
              .toList(),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      onSelected: (filter) {
        if (filter != null) {
          widget.onFilterSelected(PivotTableLevel.values.byName(filter));
        }
      },
    );
  }
}
