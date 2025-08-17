import 'package:flutter/material.dart';

PreferredSizeWidget Function(BuildContext) commonAppbar({
  String? title,
  List<Widget>? actions,
  Widget? leading,
}) {
  return (BuildContext context) => AppBar(
    title:
        title == null
            ? null
            : Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: const Color.fromARGB(45, 0, 0, 0),
                fontWeight: FontWeight.w500,
              ),
            ),
    centerTitle: true,
    actions: actions,
    leading: leading,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
  );
}
