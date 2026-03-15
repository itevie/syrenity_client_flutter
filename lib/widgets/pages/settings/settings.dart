import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_sections.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings_part_renderer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedSection = 0;
  List<SettingSection> sections = [];

  List<SettingSection> getSections() {
    return <SettingSection>[
      SettingSections.user(context),
      SettingSections.interface(context),
      SettingSections.chat(context),
      SettingSections.developer(context),
      SettingSections.about(context),
      SettingSections.logout(context),
    ];
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      sections = getSections();
    });
  }

  Widget buildSidebar(bool isDesktop) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      child: SizedBox(
        width: 220,
        child: ListView.builder(
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final selected = index == selectedSection;

            return ListTile(
              title: Text(sections[index].name),
              selected: selected,
              onTap: () async {
                switch (sections[index]) {
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
    switch (sections[selectedSection]) {
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
      child: Text("${sections[selectedSection].name}: Cannot handle"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
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
