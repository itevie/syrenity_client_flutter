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

class PageOptions {
  Widget? page;
  (VoidCallback, IconData)? fab;

  PageOptions({this.page, this.fab});
}

void Function(Widget page)? changeSettingsPagesPage;
void Function(PageOptions updatePage)? updateSettingsPagesPage;

class _SettingsPageState extends State<SettingsPage> {
  int selectedSection = 0;

  PageOptions? overridePage;

  @override
  void initState() {
    super.initState();

    changeSettingsPagesPage = (page) {
      setState(() {
        overridePage = PageOptions(page: page);
      });
    };

    updateSettingsPagesPage = (updatePage) {
      setState(() {
        overridePage = PageOptions(
          page: updatePage.page ?? overridePage?.page,
          fab: updatePage.fab ?? overridePage?.fab,
        );
      });
    };
  }

  @override
  void dispose() {
    super.dispose();
    changeSettingsPagesPage = null;
    updateSettingsPagesPage = null;
  }

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
              leading:
                  widget.sections[index].icon != null
                      ? Icon(widget.sections[index].icon)
                      : null,
              selected: selected,
              onTap: () async {
                switch (widget.sections[index]) {
                  case CallbackSettingSecttion(:final callback):
                    callback();
                    return;
                  default:
                }

                setState(() {
                  overridePage = null;
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
    if (overridePage != null) {
      return Padding(padding: EdgeInsets.all(10), child: overridePage!.page);
    }

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

  Widget? buildFab() {
    var data = overridePage?.fab;

    if (widget.sections[selectedSection] is WidgetSettingsSection &&
        (widget.sections[selectedSection] as WidgetSettingsSection).fab !=
            null) {
      data = (widget.sections[selectedSection] as WidgetSettingsSection).fab;
    }

    return data != null
        ? FloatingActionButton(onPressed: data.$1, child: Icon(data.$2))
        : null;
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
                      if (overridePage != null) {
                        setState(() {
                          overridePage = null;
                        });
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
      ),
      floatingActionButton: buildFab(),
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
