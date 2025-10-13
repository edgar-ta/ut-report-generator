import 'package:flutter/material.dart';
import 'package:ut_report_generator/components/slideshow_editor/add_slide_dialog/entry.dart';
import 'package:ut_report_generator/components/slideshow_editor/add_slide_dialog/slide_kind_preview.dart';

class AddSlideDialog extends StatefulWidget {
  final List<AddSlideEntry> entries;

  const AddSlideDialog({super.key, required this.entries});

  @override
  State<AddSlideDialog> createState() => _AddSlideDialogState();
}

class _AddSlideDialogState extends State<AddSlideDialog> {
  int _selectedOption = -1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir nueva diapositiva'),
      content: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Seleccione el tipo de diapositiva que quiere crear"),
          SizedBox(
            width: 512,
            height: 264,
            child: GridView.count(
              crossAxisCount: 2,
              scrollDirection: Axis.horizontal,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children:
                  widget.entries.indexed.map((data) {
                    final (index, entry) = data;
                    return SlideKindPreview(
                      entry: entry,
                      isSelected: _selectedOption == index,
                      setSelected: () {
                        setState(() {
                          _selectedOption = index;
                        });
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              _selectedOption != -1 ? () => Navigator.of(context).pop() : null,
          child: const Text('Siguiente'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
