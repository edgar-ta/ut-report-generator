import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

PreferredSizeWidget Function(BuildContext) commonAppbar({
  Widget? title,
  List<Widget>? actions,
  Widget? leading,
}) {
  return (BuildContext context) => AppBar(
    title: title,
    centerTitle: true,
    actions: actions,
    leading: leading,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
  );
}
