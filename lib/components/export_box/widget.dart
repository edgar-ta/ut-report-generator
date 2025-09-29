import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ut_report_generator/components/export_box/entry.dart';
import 'package:ut_report_generator/models/response/file_response.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class ExportBox extends StatefulWidget {
  ExportBoxEntry entry;
  void Function()? remove;
  void Function()? retry;

  Duration timeout;
  Duration interactionTimeout;

  ExportBox({
    super.key,
    required this.entry,
    this.remove,
    this.retry,
    this.timeout = const Duration(seconds: 15),
    this.interactionTimeout = const Duration(seconds: 10),
  });

  @override
  State<ExportBox> createState() => _ExportBoxState();
}

class _ExportBoxState extends State<ExportBox> {
  Timer? removeAfterTimeout;
  Timer? removeAfterInteraction;
  bool isHovered = false;

  void _startTimeout() {
    if (removeAfterTimeout != null) return;
    _restartTimeout();
  }

  void _restartTimeout() {
    removeAfterTimeout = Timer(widget.timeout, () {
      removeAfterTimeout = null;
      _startRemoveAfterInteraction();
    });
  }

  void _startRemoveAfterInteraction() {
    if (removeAfterTimeout != null) return;
    _cancelRemoveAfterInteraction();
    removeAfterInteraction = Timer(widget.interactionTimeout, () {
      if (!isHovered) {
        widget.remove?.call();
      }
    });
  }

  void _cancelRemoveAfterInteraction() {
    if (removeAfterInteraction != null) {
      removeAfterInteraction!.cancel();
    }
  }

  void _openDirectory(String path) {
    Process.run("explorer", [path], workingDirectory: path);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 250),
      child: Builder(
        builder: (context) {
          switch (widget.entry.status) {
            case ExportBoxEntryStatus.pending:
              return _loadingState();
            case ExportBoxEntryStatus.success:
              return _successState(widget.entry.response!);
            case ExportBoxEntryStatus.error:
              return _errorState();
          }
        },
      ),
    );
  }

  Widget _loadingState() {
    return SizedBox(
      key: ValueKey("loading"),
      width: EXPORT_BOX_WIDTH,
      height: EXPORT_BOX_HEIGHT,
      child: Card(
        elevation: 3,
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            SizedBox.square(
              dimension: EXPORT_BOX_HEIGHT,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            ),
            Expanded(child: Text("Cargando")),
            IconButton(onPressed: widget.remove, icon: Icon(Icons.close)),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    _startTimeout();
    return MouseRegion(
      onEnter: (_) {
        isHovered = true;
        _cancelRemoveAfterInteraction();
      },
      onExit: (_) {
        isHovered = false;
        _startRemoveAfterInteraction();
      },
      child: SizedBox(
        key: ValueKey("error"),
        width: EXPORT_BOX_WIDTH,
        height: EXPORT_BOX_HEIGHT,
        child: Card(
          elevation: 3,
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              SizedBox.square(
                dimension: EXPORT_BOX_HEIGHT,
                child: Icon(Icons.error, color: Colors.blueGrey[300]),
              ),
              Expanded(child: Text("Algo salió mal")),
              IconButton(onPressed: widget.retry, icon: Icon(Icons.replay)),
              IconButton(onPressed: widget.remove, icon: Icon(Icons.close)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successState(FileResponse response) {
    _startTimeout();
    final directory = File(response.filepath).parent.absolute.path;
    final filename = path.split(response.filepath).last;
    return MouseRegion(
      onEnter: (_) {
        isHovered = true;
        _cancelRemoveAfterInteraction();
      },
      onExit: (_) {
        isHovered = false;
        _startRemoveAfterInteraction();
      },
      child: SizedBox(
        key: ValueKey("normal"),
        width: EXPORT_BOX_WIDTH,
        height: EXPORT_BOX_HEIGHT,
        child: Card(
          elevation: 3,
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _openDirectory(directory);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      spacing: 6,
                      children: [
                        if (response.preview != null)
                          SizedBox.square(
                            dimension: EXPORT_BOX_HEIGHT,
                            child: Image.file(
                              File(response.preview!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            filename,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.remove?.call();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
