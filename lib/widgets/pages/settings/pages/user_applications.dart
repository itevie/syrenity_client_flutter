import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/widgets/application_widget.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class UserApplicationsPage extends StatefulWidget {
  const UserApplicationsPage({super.key});

  @override
  State<UserApplicationsPage> createState() => _UserApplicationsPageState();
}

class _UserApplicationsPageState extends State<UserApplicationsPage> {
  List<SyApplication> applications = [];

  @override
  void initState() {
    super.initState();

    loadApplications();
  }

  Future<void> loadApplications() async {
    var apps = await client.user.fetchApplications();

    setState(() {
      applications = apps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
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
                        () async {},
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
