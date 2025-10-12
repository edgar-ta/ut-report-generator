import 'package:flutter/material.dart';
import 'package:ut_report_generator/components/slideshow_editor/add_slide_dialog/entry.dart';

class SlideKindPreview extends StatefulWidget {
  final AddSlideEntry entry;
  final bool isSelected;
  final VoidCallback? setSelected;

  const SlideKindPreview({
    super.key,
    required this.entry,
    required this.isSelected,
    this.setSelected,
  });

  @override
  State<SlideKindPreview> createState() => _SlideKindPreviewState();
}

class _SlideKindPreviewState extends State<SlideKindPreview> {
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
        onTap: widget.setSelected,
        child: Expanded(
          child: Material(
            elevation: 3,
            shadowColor: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.hardEdge,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              width: 128,
              decoration: BoxDecoration(
                color:
                    widget.isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : (_isHovered
                            ? Theme.of(context).colorScheme.primaryFixedDim
                            : Theme.of(context).colorScheme.primaryContainer),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: widget.entry.preview,
                      ),
                    ),
                    Text(
                      widget.entry.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
