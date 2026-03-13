import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'server.dart';
import 'channel.dart';

class SyInvite {
  final SyrenityClient client;

  final String id;
  final int guildId;
  final int? channelId;
  final int createdBy;
  final DateTime createdAt;
  final int expiresIn;
  final int maxUses;
  final int uses;

  final SyServer guild;
  final SyChannel? channel;

  SyInvite(
    this.client, {
    required this.id,
    required this.guildId,
    required this.channelId,
    required this.createdBy,
    required this.createdAt,
    required this.expiresIn,
    required this.maxUses,
    required this.uses,
    required this.guild,
    required this.channel,
  });

  factory SyInvite.build(SyrenityClient client, Map<String, dynamic> json) {
    return SyInvite(
      client,
      id: json['id'] as String,
      guildId: json['guild_id'] as int,
      channelId: json['channel_id'] as int?,
      createdBy: json['created_by'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresIn: json['expires_in'] as int,
      maxUses: json['max_uses'] as int,
      uses: json['uses'] as int,
      guild: SyServer.build(client, json['guild'] as Map<String, dynamic>),
      channel:
          json['channel'] != null
              ? SyChannel.build(client, json['channel'] as Map<String, dynamic>)
              : null,
    );
  }

  Future<void> use() async {
    await client.http.post("/api/invites/$id", null, null);
  }
}
