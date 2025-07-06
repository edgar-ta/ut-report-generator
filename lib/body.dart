import 'package:desktop_updater/updater_controller.dart';
import 'package:flutter/material.dart';
import 'package:desktop_updater/desktop_updater.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late DesktopUpdaterController _desktopUpdaterController;

  @override
  void initState() {
    super.initState();
    _desktopUpdaterController = DesktopUpdaterController(
      appArchiveUrl: Uri.parse(
        "https://www.github.com/edgar-ta/ut-report-generator/tree/2025-06-07--desktop-updater-integration/assets/app-archive.json",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Theme(
              data: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                ).copyWith(
                  onSurface: Theme.of(context).colorScheme.onSurface,
                  onSurfaceVariant:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  primary: Theme.of(context).colorScheme.primary,
                  surfaceContainerLowest:
                      Theme.of(context).colorScheme.surfaceContainerLowest,
                  surfaceContainerLow:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  surfaceContainerHighest:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              child: DesktopUpdateDirectCard(
                controller: _desktopUpdaterController,
                child: const Text("This is a child widget"),
              ),
            ),
            const Text("Hello world!"),
            const Text("Running on: 1.0.1+1"),
          ],
        ),
      ),
    );
  }
}
