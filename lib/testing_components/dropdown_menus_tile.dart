import 'package:flutter/material.dart';

class DropdownMenusTile<T> extends StatefulWidget {
  final String title;
  final List<T> items;

  final T? selected;

  final Widget Function(BuildContext context, T value) itemBuilder;

  final void Function(T value) onChanged;

  final int index;

  const DropdownMenusTile({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
    required this.itemBuilder,
    required this.onChanged,
    required this.index,
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
                child: ReorderableDragStartListener(
                  index: widget.index,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.move,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
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
                  // Dropdown secundario (normal)
                  DropdownButtonFormField<T>(
                    value: widget.selected,
                    items:
                        widget.items.map((item) {
                          return DropdownMenuItem<T>(
                            value: item,
                            child: widget.itemBuilder(context, item),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) widget.onChanged(value);
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
