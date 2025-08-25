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
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
        child: Row(
          children: [
            // Botón para drag & drop
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

            // Título
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

            // DropdownMenu con ancho máximo
            SizedBox(
              width: 256,
              child: DropdownMenu<T>(
                initialSelection: widget.selected,
                dropdownMenuEntries:
                    widget.items.map((item) {
                      return DropdownMenuEntry<T>(
                        value: item,
                        label:
                            item.toString(), // usamos child en lugar de label
                        labelWidget: widget.itemBuilder(context, item),
                      );
                    }).toList(),
                onSelected: (value) {
                  if (value != null) {
                    widget.onChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
