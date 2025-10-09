import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class StartupButtonItem extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String title;
  const StartupButtonItem({
    super.key,
    this.onTap,
    required this.icon,
    required this.title,
  });

  @override
  State<StartupButtonItem> createState() => _StartupButtonItemState();
}

class _StartupButtonItemState extends State<StartupButtonItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? Theme.of(context).colorScheme.primaryFixedDim
                    : Theme.of(context).colorScheme.primaryContainer,
          ),
          duration: Duration(milliseconds: 250),
          height: STARTUP_BUTTON_HEIGHT,
          child: Row(
            spacing: 8,
            children: [
              Icon(
                widget.icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
