import 'package:flutter/material.dart';

/// Entrada para ChipsTile
class ChipsTileEntry<T> {
  final Key key;
  final T value;
  final bool selected;

  ChipsTileEntry({
    required this.key,
    required this.value,
    this.selected = false,
  });
}

/// Widget ChipsTile genérico
class ChipsTile<T> extends StatefulWidget {
  final String title;
  final List<ChipsTileEntry<T>> entries;
  final Widget Function(BuildContext context, T value, bool selected)
  chipBuilder;
  final VoidCallback? onDelete;
  final int index;

  const ChipsTile({
    super.key,
    required this.title,
    required this.entries,
    required this.chipBuilder,
    required this.index,
    this.onDelete,
  });

  @override
  State<ChipsTile<T>> createState() => _ChipsTileState<T>();
}

class _ChipsTileState<T> extends State<ChipsTile<T>> {
  bool _expanded = false;
  bool _hovering = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Controles laterales (handle + borrar) con fade in/out
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _hovering ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_hovering,
              child: Row(
                children: [
                  // Botón de handle
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
                  // Botón de borrar
                  if (widget.onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: widget.onDelete,
                      tooltip: 'Eliminar',
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Contenido expandible
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Título
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    // Botón expand/collapse
                    IconButton(
                      onPressed: _toggleExpanded,
                      icon: AnimatedRotation(
                        turns: _expanded ? 0.5 : 0.0, // 0.0 = down, 0.5 = up
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ),
                  ],
                ),

                // Contenido expandible
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState:
                      _expanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  firstChild: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.entries
                            .map(
                              (entry) => widget.chipBuilder(
                                context,
                                entry.value,
                                entry.selected,
                              ),
                            )
                            .toList(),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
