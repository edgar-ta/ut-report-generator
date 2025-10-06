import 'package:flutter/material.dart';
import 'package:ut_report_generator/components/home/startup_button/entry.dart';
import 'package:ut_report_generator/components/home/startup_button/item.dart';
import 'package:ut_report_generator/components/home/startup_button/state.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class StartupButton<K> extends StatefulWidget {
  final StartupButtonState<K> state;
  final void Function(StartupButtonState<K> Function(StartupButtonState<K>))
  setState;

  final List<StartupButtonEntry<K>> entries;
  final void Function(K) onValueSelected;

  const StartupButton({
    super.key,
    required this.state,
    required this.setState,
    required this.entries,
    required this.onValueSelected,
  });

  @override
  State<StartupButton<K>> createState() => _StartupButtonState<K>();
}

class _StartupButtonState<K> extends State<StartupButton<K>>
    with SingleTickerProviderStateMixin {
  void _toggleDropdown() {
    if (widget.state.isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _controller.show();
    widget.setState((state) => state..isOpen = true);
  }

  void _closeDropdown() {
    _controller.hide();
    widget.setState((state) => state..isOpen = false);
  }

  final OverlayPortalController _controller = OverlayPortalController();
  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return _segmentedButton();
    } else {
      final offset = renderBox.localToGlobal(Offset.zero);

      return OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          return Positioned(
            width: 256,
            top: offset.dy + 8,
            left: offset.dx - 80,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              opacity: widget.state.isOpen ? 1 : 0,
              child: _entriesList(),
            ),
          );
        },
        child: _segmentedButton(),
      );
    }
  }

  Widget _segmentedButton() {
    final selectedEntry = widget.entries.firstWhere(
      (entry) => entry.value == widget.state.selectedValue,
    );

    return SizedBox(
      key: key,
      height: STARTUP_BUTTON_HEIGHT,
      width: 256,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                widget.setState((state) => state..isOpen = false);
                widget.onValueSelected(widget.state.selectedValue);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              child: Text(selectedEntry.title),
            ),
          ),
          IconButton(
            onPressed: _toggleDropdown,
            icon: AnimatedRotation(
              turns: widget.state.isOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(Icons.keyboard_arrow_down),
            ),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entriesList() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            widget.entries
                .map(
                  (element) => StartupButtonItem(
                    icon: element.icon,
                    title: element.title,
                    onTap: () {
                      widget.setState(
                        (state) =>
                            (state..isOpen = false)
                              ..selectedValue = element.value,
                      );
                      widget.onValueSelected(element.value);
                    },
                  ),
                )
                .toList(),
      ),
    );
  }
}
