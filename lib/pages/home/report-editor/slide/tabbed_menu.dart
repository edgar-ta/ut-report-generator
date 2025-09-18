import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class TabbedMenu extends StatefulWidget {
  final WidgetBuilder editTabBuilder;
  final WidgetBuilder metadataTabBuilder;

  const TabbedMenu({
    Key? key,
    required this.editTabBuilder,
    required this.metadataTabBuilder,
  }) : super(key: key);

  @override
  State<TabbedMenu> createState() => _TabbedMenuState();
}

class _TabbedMenuState extends State<TabbedMenu>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MENU_WIDTH,
      child: Column(
        children: [
          TabBar(
            controller: _controller,
            tabs: const [
              Tab(
                icon: Icon(Icons.edit), // Ícono para Edición
                text: "Edición",
              ),
              Tab(
                icon: Icon(Icons.info_outline), // Ícono para Metadatos
                text: "Metadatos",
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                Builder(builder: widget.editTabBuilder),
                Builder(builder: widget.metadataTabBuilder),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
