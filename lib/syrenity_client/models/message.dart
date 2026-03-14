import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'user.dart';
import 'reaction.dart';
import 'webhook.dart';

class SyMessage {
  final SyrenityClient client;

  final int id;
  final String content;
  final int channelId;
  final DateTime createdAt;

  final int authorId;
  final SyUser author;

  final bool isPinned;
  final bool isEdited;
  final bool isSystem;
  final String? sysType;

  final List<SyReaction> reactions;

  final String? webhookId;
  final SyWebhook? webhook;

  final int? proxyId;

  SyMessage(
    this.client, {
    required this.id,
    required this.content,
    required this.channelId,
    required this.createdAt,
    required this.authorId,
    required this.author,
    required this.isPinned,
    required this.isEdited,
    required this.isSystem,
    required this.sysType,
    required this.reactions,
    required this.webhookId,
    required this.webhook,
    required this.proxyId,
  });

  factory SyMessage.build(SyrenityClient client, Map<String, dynamic> json) {
    return SyMessage(
      client,
      id: json['id'] as int,
      content: json['content'] as String,
      channelId: json['channel_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),

      authorId: json['author_id'] as int,
      author: SyUser.build(client, json['author'] as Map<String, dynamic>),

      isPinned: json['is_pinned'] as bool,
      isEdited: json['is_edited'] as bool,
      isSystem: json['is_system'] as bool,
      sysType: json['sys_type'] as String?,

      reactions:
          (json['reactions'] as List<dynamic>)
              .map((e) => SyReaction.build(client, e as Map<String, dynamic>))
              .toList(),

      webhookId: json['webhook_id'] as String?,
      webhook:
          json['webhook'] == null
              ? null
              : SyWebhook.build(
                client,
                json['webhook'] as Map<String, dynamic>,
              ),

      proxyId: json['proxy_id'] as int?,
    );
  }

  Future<void> delete() async {
    await client.http.rawDelete('/api/channels/$channelId/messages/$id', null);
  }
}
