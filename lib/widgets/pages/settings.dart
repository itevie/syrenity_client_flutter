import 'package:dawn_ui_flutter/prompts/confirm.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syrenity_client_flutter/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedSection = 0;

  final sections = [
    "Account",
    "Privacy",
    "Notifications",
    "Appearance",
    "Log Out",
  ];

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
              title: Text(sections[index]),
              selected: selected,
              onTap: () async {
                if (sections[index] == "Log Out") {
                  final conf = await showConfirmPrompt(
                    context,
                    const Text("Logout"),
                    const Text("Are you sure you want to logout?"),
                  );
                  if (conf) {
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.remove("token");
                    setupClient(login: false);
                    reload();
                  }
                }

                setState(() {
                  selectedSection = index;
                });

                if (!isDesktop) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context); // close drawer
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildContent() {
    return Center(
      child: Text(
        sections[selectedSection],
        style: const TextStyle(fontSize: 24),
      ),
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
