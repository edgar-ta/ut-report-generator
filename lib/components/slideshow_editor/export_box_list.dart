import 'package:flutter/material.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box/entry.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box/widget.dart';

class ExportBoxList extends StatelessWidget {
  final GlobalKey<AnimatedListState> exportsListKey;
  final List<ExportBoxEntry> exports;
  final void Function(ExportBoxEntry) removeExport;
  final void Function(ExportBoxEntry) retryExport;

  const ExportBoxList({
    super.key,
    required this.exportsListKey,
    required this.exports,
    required this.removeExport,
    required this.retryExport,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: exportsListKey,
      itemBuilder: (context, index, animation) {
        final entry = exports[index];
        return ExportBox(
          timeout: Duration(seconds: 3),
          interactionTimeout: Duration(seconds: 1),
          key: ValueKey(entry.identifier),
          entry: entry,
          retry: () => retryExport(entry),
          remove: () => removeExport(entry),
        );
      },
      initialItemCount: exports.length,
    );
  }
}
