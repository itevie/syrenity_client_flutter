import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'channel.dart';
import 'user.dart';

class SyRelationship {
  final SyrenityClient client;

  final int channelId;
  final SyChannel channel;
  final SyUser user1;
  final SyUser user2;
  final String lastMessage;
  final bool activeUser1;
  final bool activeUser2;
  final bool isFriends;
  final DateTime createdAt;

  SyUser get self {
    return client.user.id == user1.id ? user1 : user2;
  }

  SyUser get recipient {
    return client.user.id == user1.id ? user2 : user1;
  }

  SyRelationship(
    this.client, {
    required this.channelId,
    required this.channel,
    required this.user1,
    required this.user2,
    required this.lastMessage,
    required this.activeUser1,
    required this.activeUser2,
    required this.isFriends,
    required this.createdAt,
  });

  factory SyRelationship.build(
    SyrenityClient client,
    Map<String, dynamic> json,
  ) {
    return SyRelationship(
      client,
      channelId: json['channel_id'] as int,
      channel: SyChannel.build(client, json['channel'] as Map<String, dynamic>),
      user1: SyUser.build(client, json['user1'] as Map<String, dynamic>),
      user2: SyUser.build(client, json['user2'] as Map<String, dynamic>),
      lastMessage: json['last_message'] as String,
      activeUser1: json['active_user_1'] as bool,
      activeUser2: json['active_user_2'] as bool,
      isFriends: json['is_friends'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
