import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/user.dart';

class SyMember {
  final SyrenityClient client;

  final int guildId;
  final int userId;
  final String? nickname;
  final SyUser? user;

  SyMember(
    this.client, {
    required this.guildId,
    required this.userId,
    required this.nickname,
    required this.user,
  });

  factory SyMember.build(SyrenityClient client, Map<String, dynamic> json) {
    return SyMember(
      client,
      guildId: json['guild_id'] as int,
      userId: json['user_id'] as int,
      nickname: json['nickname'] as String?,
      user: json['user'] == null ? null : SyUser.build(client, json['user']),
    );
  }
}
