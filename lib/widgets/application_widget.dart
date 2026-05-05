import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/widgets/avatar_with_status.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

Widget createApplicationWidget(
  BuildContext context,
  SyApplication application,
  VoidCallback onTap,
) => InkWell(
  onTap: onTap,
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        AvatarWithStatus(userId: application.botAccount, size: 64),
        const SizedBox(height: 8),
        Text(
          application.applicationName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          "By ${application.owner.username}",
          style: const TextStyle(fontSize: 12),
        ),
        const Divider(),
        Text(
          application.description ?? "No Description",
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
);
