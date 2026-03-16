import 'package:dawn_ui_flutter/dawn_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/avatar_with_status.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings.dart';

class SelfSection extends StatefulWidget {
  const SelfSection({super.key});

  @override
  State<StatefulWidget> createState() => _SelfSectionState();
}

class _SelfSectionState extends State<SelfSection> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (client.scaryUser == null) {
      return Container(
        height: SyrenityTheme.bottomBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4),

        decoration: BoxDecoration(color: colors.inversePrimary),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final userStore = context.watch<UserStore>();
    final user = userStore[client.user.id]!;

    return Container(
      height: SyrenityTheme.bottomBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),

      decoration: BoxDecoration(color: colors.inversePrimary),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(20),
            color: colors.surface.withValues(alpha: 0.95),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarWithStatus(userId: user.id),
                    const SizedBox(width: 8),
                    Text(
                      user.username,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              navigate(context, SettingsPage());
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
