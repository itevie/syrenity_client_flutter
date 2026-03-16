import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/custom_status_store.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';

class AvatarWithStatus extends StatefulWidget {
  final int userId;
  final double size;
  const AvatarWithStatus({super.key, this.size = 20, required this.userId});

  @override
  State<StatefulWidget> createState() => _AvatarWithStatusState();
}

class _AvatarWithStatusState extends State<AvatarWithStatus> {
  Color _statusColor(String? visibility) {
    switch (visibility) {
      case "online":
        return Colors.green;
      case "idle":
        return Colors.orange;
      case "dnd":
        return Colors.red;
      case "invisible":
      case "offline":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStore = context.watch<UserStore>();
    final customStatusStore = context.watch<CustomStatusStore>();

    final user = userStore[widget.userId]!;
    final status = customStatusStore[widget.userId];

    final avatar = client.fileBase.from(user.avatar);

    return Stack(
      children: [
        CircleAvatar(
          key: Key(user.id.toString()),
          radius: widget.size,
          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
        ),

        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _statusColor(status?.visibility),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
