import 'package:flutter/material.dart';
import 'package:ut_report_generator/home/_main.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
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
                    label: Text("fjsl"),
                  ),
                ],
                selectedIndex: 0,
                onDestinationSelected: (value) {},
              ),
              VerticalDivider(thickness: 1, width: 1),
              Expanded(child: Center(child: HomePage())),
            ],
          ),
        ),
      ),
    );
  }
}
