import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';

class SlideMetadataPane extends StatelessWidget {
  final String identifier;
  final DateTime creationDate;
  final String preview;
  final SlideCategory category;

  const SlideMetadataPane({
    super.key,
    required this.identifier,
    required this.creationDate,
    required this.preview,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        LabeledContent(text: identifier, name: "Id", icon: Icons.perm_identity),
        LabeledContent(
          text: creationDate.relativeTimeLocale(Locale('es', "MX")),
          name: "Fecha de creación",
          icon: Icons.calendar_today,
        ),
        LabeledContent(
          text: category.name,
          name: "Tipo de diapositiva",
          icon: Icons.category,
        ),
        LabeledContent(
          text: preview,
          name: "Vista previa",
          icon: Icons.preview,
        ),
      ],
    );
  }
}

class LabeledContent extends StatelessWidget {
  const LabeledContent({
    super.key,
    required this.text,
    required this.name,
    required this.icon,
  });

  final String text;
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(icon, size: 14),
                ),
              ),
              TextSpan(text: name),
            ],
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          child: Text(
            text.replaceFirstMapped(
              RegExp(r'^(.)'),
              (match) => match.group(1)!.toUpperCase(),
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
