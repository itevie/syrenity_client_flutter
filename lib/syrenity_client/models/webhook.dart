import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'proxy_user.dart';

class SyWebhook {
  final SyrenityClient client;

  final String id;
  final int proxyUserId;
  final SyProxyUser proxyUser;
  final String? description;
  final int channelId;
  final int serverId;
  final int? creatorId;
  final DateTime createdAt;

  SyWebhook(
    this.client, {
    required this.id,
    required this.proxyUserId,
    required this.proxyUser,
    required this.description,
    required this.channelId,
    required this.serverId,
    required this.creatorId,
    required this.createdAt,
  });

  factory SyWebhook.build(SyrenityClient client, Map<String, dynamic> json) {
    return SyWebhook(
      client,
      id: json['id'] as String,
      proxyUserId: json['proxy_user_id'] as int,
      proxyUser: SyProxyUser.build(
        client,
        json['proxy_user'] as Map<String, dynamic>,
      ),
      description: json['description'] as String?,
      channelId: json['channel_id'] as int,
      serverId: json['server_id'] as int,
      creatorId: json['creator_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
