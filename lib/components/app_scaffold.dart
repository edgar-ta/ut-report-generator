import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/components/common_appbar.dart';
import 'package:ut_report_generator/components/footer_component.dart';
import 'package:ut_report_generator/components/header_component.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class AppScaffold extends StatefulWidget {
  StatefulNavigationShell child;

  AppScaffold({super.key, required this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    final appBarBuilder = context.watch<ScaffoldController>().appBarBuilder;
    final fabBuilder = context.watch<ScaffoldController>().fabBuilder;

    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton:
          fabBuilder != null ? fabBuilder(context) : SizedBox.shrink(),
      appBar:
          appBarBuilder != null
              ? appBarBuilder(context)
              : commonAppbar()(context),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.house),
                      label: Text("Inicio"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text("Perfil"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bug_report),
                      label: Text("Reportar errores"),
                    ),
                  ],
                  selectedIndex: widget.child.currentIndex,
                  onDestinationSelected: (index) {
                    widget.child.goBranch(index);
                  },
                ),
                VerticalDivider(thickness: 1, width: 1),
                Expanded(child: widget.child),
              ],
            ),
          ),
          FooterComponent(),
        ],
      ),
    );
  }
}
