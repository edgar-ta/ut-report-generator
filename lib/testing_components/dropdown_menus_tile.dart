import 'package:flutter/material.dart';

class DropdownMenusTile<T> extends StatefulWidget {
  final String title;
  final List<T> primaryItems;
  final List<T> secondaryItems;

  final T? selectedPrimary;
  final T? selectedSecondary;

  final Widget Function(BuildContext context, T value) primaryItemBuilder;
  final Widget Function(BuildContext context, T value) secondaryItemBuilder;

  final void Function(T value) onPrimaryChanged;
  final void Function(T value) onSecondaryChanged;

  final int index;
  final VoidCallback onDelete;

  const DropdownMenusTile({
    super.key,
    required this.title,
    required this.primaryItems,
    required this.secondaryItems,
    required this.selectedPrimary,
    required this.selectedSecondary,
    required this.primaryItemBuilder,
    required this.secondaryItemBuilder,
    required this.onPrimaryChanged,
    required this.onSecondaryChanged,
    required this.index,
    required this.onDelete,
  });

  @override
  State<DropdownMenusTile<T>> createState() => _DropdownMenusTileState<T>();
}

class _DropdownMenusTileState<T> extends State<DropdownMenusTile<T>> {
  bool _expanded = false;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Column(
        children: [
          Row(
            children: [
              // Botones de control
              AnimatedOpacity(
                opacity: _hovering ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: InkWell(
                        mouseCursor: SystemMouseCursors.move,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.drag_handle),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: widget.onDelete,
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(widget.title),
                  trailing: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0, // flecha arriba/abajo
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () => setState(() => _expanded = !_expanded),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
                _expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Dropdown principal (no editable)
                  DropdownButtonFormField<T>(
                    value: widget.selectedPrimary,
                    items:
                        widget.primaryItems.map((item) {
                          return DropdownMenuItem<T>(
                            value: item,
                            child: widget.primaryItemBuilder(context, item),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) widget.onPrimaryChanged(value);
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 12),
                  // Dropdown secundario (normal)
                  DropdownButtonFormField<T>(
                    value: widget.selectedSecondary,
                    items:
                        widget.secondaryItems.map((item) {
                          return DropdownMenuItem<T>(
                            value: item,
                            child: widget.secondaryItemBuilder(context, item),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) widget.onSecondaryChanged(value);
                    },
                    isExpanded: true,
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
