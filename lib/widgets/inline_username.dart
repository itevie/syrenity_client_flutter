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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            userA.username,
            style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (userA.isBot) ...[
          SizedBox(width: 4),
          SizedBox(
            height: 20,
            child: Container(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),

              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
                child: Center(
                  child: Text(
                    "Bot",
                    style: TextStyle(color: colors.onPrimary, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
