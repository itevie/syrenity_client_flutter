import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/widgets/avatar_with_status.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class UserViewerModal extends StatelessWidget {
  final SyUser user;

  const UserViewerModal({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 172,
                width: double.infinity,
                child: Image.network(
                  client.fileBase.from(user.profileBanner) ??
                      client.fileBase.badUrl,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                left: 16,
                bottom: -40, // half outside banner
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  child: AvatarWithStatus(userId: user.id, size: 38),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    user.username,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user.bio != null && user.bio!.isNotEmpty)
                            Text(user.bio ?? ""),

                          Text(
                            "Joined Syrenity",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(DateFormat.yMMMMd().format(user.createdAt)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
