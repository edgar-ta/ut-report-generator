import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  Widget? title;
  List<Widget>? actions;
  Widget? leading;

  CommonAppbar({super.key, this.title, this.actions, this.leading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      centerTitle: true,
      toolbarHeight: APP_BAR_HEIGHT,
      actions: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset("assets/soy-ut-logo.png"),
              Image.asset("assets/ut-logos.png"),
            ],
          ),
        ),
        if (actions != null) ...actions!,
      ],
      leading: leading,
      backgroundColor: BLUE_COLOR,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(APP_BAR_HEIGHT);
}
