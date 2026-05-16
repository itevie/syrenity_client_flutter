import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';

class InlineUsername extends StatelessWidget {
  final int user;
  final bool owner;
  final bool bold;
  const InlineUsername({
    super.key,
    required this.user,
    this.owner = false,
    this.bold = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final userStore = context.watch<UserStore>();
    final userA = userStore[user]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          userA.username,
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),

        if (userA.isBot) ...[
          const SizedBox(width: 4),

          Container(
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              "Bot",
              style: TextStyle(color: colors.onPrimary, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
