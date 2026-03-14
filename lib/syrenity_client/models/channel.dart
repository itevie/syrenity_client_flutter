import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/message.dart';

class ChannelMessageQueryOptions {
  final int? amount;
  final int? startAt;
  final int? fromUser;
  final bool? isPinned;

  ChannelMessageQueryOptions({
    this.amount,
    this.startAt,
    this.fromUser,
    this.isPinned,
  });
}

enum SyChannelType {
  channel,
  dm;

  static SyChannelType fromString(String value) {
    switch (value) {
      case 'channel':
        return SyChannelType.channel;
      case 'dm':
        return SyChannelType.dm;
      default:
        throw ArgumentError('Invalid channel type: $value');
    }
  }

  String toJson() => name;
}

class SyChannel {
  final SyrenityClient client;

  final int id;
  final SyChannelType type;
  final int? guildId;
  final String name;
  final String? topic;
  final bool isNsfw;
  final int position;

  SyChannel(
    this.client, {
    required this.id,
    required this.type,
    required this.guildId,
    required this.name,
    required this.topic,
    required this.isNsfw,
    required this.position,
  });

  factory SyChannel.build(SyrenityClient client, Map<String, dynamic> json) {
    final channel = SyChannel(
      client,
      id: json['id'] as int,
      type: SyChannelType.fromString(json['type'] as String),
      guildId: json['guild_id'] as int?,
      name: json['name'] as String,
      topic: json['topic'] as String?,
      isNsfw: json['is_nsfw'] as bool,
      position: json['position'] as int,
    );

    client.events.emit(SyEvents.createChannel, channel);

    return channel;
  }

  Future<SyMessage> send(String content) async {
    return await client.http.post<SyMessage, Map<String, dynamic>>(
      "/api/channels/$id/messages",
      {'content': content},
      (client, value) => SyMessage.build(client, value),
    );
  }

  Future<void> startTyping() async {
    await client.http.post("/api/channels/$id/start-typing", {}, null);
  }

  Future<List<SyMessage>> query([ChannelMessageQueryOptions? options]) async {
    final queryParams = <String, String>{};

    if (options?.amount != null) {
      queryParams['amount'] = options!.amount.toString();
    }
    if (options?.fromUser != null) {
      queryParams['from_user'] = options!.fromUser!.toString();
    }
    if (options?.isPinned != null) {
      queryParams['is_pinned'] = options!.isPinned.toString();
    }
    if (options?.startAt != null) {
      queryParams['start_at'] = options!.startAt!.toString();
    }

    final queryString =
        queryParams.entries.isNotEmpty
            ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
            : '';

    return await client.http.get<List<SyMessage>, List<dynamic>>(
      "/api/channels/$id/messages$queryString",
      (c, x) => x.map((v) => SyMessage.build(client, v)).toList(),
    );
  }
}
