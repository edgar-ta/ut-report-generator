import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/api/slideshow/self.dart' as slideshow_api;

class SlideshowPreviewCard extends StatefulWidget {
  final String name;
  final String preview;
  final VoidCallback? openPreview;
  final Future<void> Function()? deletePreview;
  final String lastOpen;

  const SlideshowPreviewCard({
    super.key,
    required this.name,
    required this.preview,
    required this.lastOpen,
    this.openPreview,
    this.deletePreview,
  });

  @override
  State<SlideshowPreviewCard> createState() => _SlideshowPreviewCardState();
}

class _SlideshowPreviewCardState extends State<SlideshowPreviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.openPreview,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: SLIDESHOW_PREVIEW_HEIGHT,
          width: SLIDESHOW_PREVIEW_HEIGHT * 16 / 9,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                _isHovered
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: AnimatedScale(
                        scale: _isHovered ? 1.05 : 1,
                        duration: Duration(milliseconds: 200),
                        child: Image.file(
                          File(widget.preview),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.timelapse,
                                      size: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryFixedVariant,
                                    ),
                                  ),
                                ),
                                TextSpan(text: "Abierto ${widget.lastOpen}"),
                              ],
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryFixedVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(top: 8, right: 8, child: _deleteButton()),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedOpacity _deleteButton() {
    return AnimatedOpacity(
      opacity: _isHovered ? 1 : 0,
      duration: Duration(milliseconds: 250),
      child: InkWell(
        onTap: widget.deletePreview,
        splashColor: Colors.blueGrey[50],
        highlightColor: Colors.blue,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.delete, size: 20, color: Colors.blueGrey[800]),
        ),
      ),
    );
  }
}
