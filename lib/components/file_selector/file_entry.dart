import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FileEntry extends StatefulWidget {
  final bool isSelected;
  final void Function() toggleSelected;
  final String path;

  const FileEntry({
    super.key,
    required this.isSelected,
    required this.toggleSelected,
    required this.path,
  });

  @override
  State<FileEntry> createState() => _FileEntryState();
}

class _FileEntryState extends State<FileEntry> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final pathComponents = path.split(widget.path);
    String filename = pathComponents.last;
    String rootPath = pathComponents
        .take(pathComponents.length - 1)
        .join(path.separator);

    return MouseRegion(
      onEnter:
          (_) => setState(() {
            isHovered = true;
          }),
      onExit:
          (_) => setState(() {
            isHovered = false;
          }),
      child: ListTile(
        title: AnimatedOpacity(
          opacity: isHovered ? 1 : 0.8,
          duration: Duration(milliseconds: 100),
          child: Text(filename),
        ),
        leading: AnimatedOpacity(
          opacity: (isHovered || widget.isSelected) ? 1 : 0.25,
          duration: Duration(milliseconds: 250),
          child: SizedBox.square(
            dimension: 64,
            child: Checkbox(
              value: widget.isSelected,
              onChanged: (_) {
                widget.toggleSelected();
              },
            ),
          ),
        ),
        subtitle: AnimatedOpacity(
          opacity: isHovered ? 1 : 0.25,
          duration: Duration(milliseconds: 250),
          child: Text(rootPath),
        ),
      ),
    );
  }
}
