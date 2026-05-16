import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_sections.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings_part_renderer.dart';

class SettingsPage extends StatefulWidget {
  final List<SettingSection> sections;
  final String name;

  const SettingsPage({
    super.key,
    required this.sections,
    this.name = "Settings",
  });

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedSection = 0;

  Widget buildSidebar(bool isDesktop) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      child: SizedBox(
        width: 220,
        child: ListView.builder(
          itemCount: widget.sections.length,
          itemBuilder: (context, index) {
            final selected = index == selectedSection;

            return ListTile(
              title: Text(widget.sections[index].name),
              selected: selected,
              onTap: () async {
                switch (widget.sections[index]) {
                  case CallbackSettingSecttion(:final callback):
                    callback();
                    return;
                  default:
                }

                setState(() {
                  selectedSection = index;
                });

                if (!isDesktop) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildContent() {
    switch (widget.sections[selectedSection]) {
      case WidgetSettingsSection(:final widget):
        return Padding(padding: EdgeInsets.all(10), child: widget());
      case PartsSettingSection(:final parts):
        return Padding(
          padding: EdgeInsets.all(10),
          child: SettingsPartRenderer(parts: parts),
        );
      default:
    }

    return Center(
      child: Text("${widget.sections[selectedSection].name}: Cannot handle"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions:
            isDesktop
                ? []
                : [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
      ),
      drawer: isDesktop ? null : Drawer(child: buildSidebar(isDesktop)),
      body:
          isDesktop
              ? Row(
                children: [
                  buildSidebar(isDesktop),
                  const VerticalDivider(width: 1),
                  Expanded(child: buildContent()),
                ],
              )
              : buildContent(),
    );
  }
}
