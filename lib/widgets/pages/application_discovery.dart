import 'package:dawn_ui_flutter/dawn_ui.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/application_widget.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/show_top_overlay.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class ApplicationDiscovery extends StatefulWidget {
  const ApplicationDiscovery({super.key});

  @override
  State<StatefulWidget> createState() => _ApplicationDiscoveryState();
}

class _ApplicationDiscoveryState extends State<ApplicationDiscovery> {
  List<SyApplication> applications = [];

  void load() async {
    final loadedApplications = await client.applications.fetchPublic();

    setState(() {
      applications = loadedApplications;
    });
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: SyrenityTheme.topBarHeight,
          color: colors.surfaceContainer,
          child: Center(child: Text("Application Discovery")),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Wrap(
            children: [
              ...applications.map((application) {
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: SizedBox(
                    height: 256,
                    width: 196,
                    child: ContextMenu(
                      onTapToo: true,
                      items: () => [ContextMenuSeparator()],
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        child: createApplicationWidget(
                          context,
                          application,
                          () async {
                            final servers = (await client.servers.fetchAll())
                                .where((x) => x.ownerId == client.user.id);

                            final selector = await showSelectPrompt(
                              // ignore: use_build_context_synchronously
                              context,
                              Text("Select Server"),
                              Map.fromEntries(
                                servers.map((x) => MapEntry(x.id, x.name)),
                              ),
                            );

                            if (selector == null) return;

                            await application.inviteTo(selector);
                            showTopOverlay(
                              // ignore: use_build_context_synchronously
                              context,
                              "Added ${application.bot.username} to ${servers.firstWhere((x) => x.id == selector).name}",
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
