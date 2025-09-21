import 'dart:io';

import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class ReportPreviewCard extends StatefulWidget {
  final String name;
  final String preview;
  final VoidCallback? onTap;
  final String lastOpen;

  const ReportPreviewCard({
    super.key,
    required this.name,
    required this.preview,
    required this.lastOpen,
    this.onTap,
  });

  @override
  State<ReportPreviewCard> createState() => _ReportPreviewCardState();
}

class _ReportPreviewCardState extends State<ReportPreviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AnimatedScale(
                  scale: _isHovered ? 1.05 : 1,
                  duration: Duration(milliseconds: 200),
                  child: Image.file(File(widget.preview), fit: BoxFit.cover),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
      ),
    );
  }
}
