import 'package:syrenity_client_flutter/syrenity_client/client.dart';

class SyMember {
  final SyrenityClient client;

  final int guildId;
  final int userId;
  final String? nickname;

  SyMember(
    this.client, {
    required this.guildId,
    required this.userId,
    required this.nickname,
  });

  factory SyMember.build(SyrenityClient client, Map<String, dynamic> json) {
    return SyMember(
      client,
      guildId: json['guild_id'] as int,
      userId: json['user_id'] as int,
      nickname: json['nickname'] as String?,
    );
  }
}
