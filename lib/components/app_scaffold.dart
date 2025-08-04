import 'package:flutter/material.dart';
import 'package:ut_report_generator/bugs/_main.dart';
import 'package:ut_report_generator/home/_main.dart';
import 'package:ut_report_generator/main_app.dart';
import 'package:ut_report_generator/profile/_main.dart';

class AppScaffold extends StatefulWidget {
  Future<bool> Function(int)? allowNewDestination;
  Widget? child;

  AppScaffold({super.key, this.allowNewDestination, this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var pages = [ProfilePage(), HomePage(), BugReportPage()];

    return MaterialApp(
      title: "UT Report Generator",
      home: Scaffold(
        body: Center(
          child: Row(
            children: [
              NavigationRail(
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.house),
                    label: Text("Inicio"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text("Cuenta"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bug_report),
                    label: Text("Reportar errores"),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) async {
                  var isAllowed = true;
                  if (widget.allowNewDestination != null) {
                    isAllowed = await widget.allowNewDestination!(value);
                  }

                  if (isAllowed) {
                    setState(() {
                      selectedIndex = value;
                    });
                  }
                },
              ),
              VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Center(child: widget.child ?? pages[selectedIndex]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
