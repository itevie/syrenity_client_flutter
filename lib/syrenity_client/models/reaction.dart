import 'package:syrenity_client_flutter/syrenity_client/client.dart';

class SyReaction {
  final SyrenityClient client;

  final int messageId;
  final String emoji;
  final DateTime createdAt;
  final int amount;
  final List<int> users;

  SyReaction(
    this.client, {
    required this.messageId,
    required this.emoji,
    required this.createdAt,
    required this.amount,
    required this.users,
  });

  factory SyReaction.build(SyrenityClient client, Map<String, dynamic> json) {
    return SyReaction(
      client,
      messageId: json['message_id'] as int,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      amount: json['amount'] as int,
      users: (json['users'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }
}
