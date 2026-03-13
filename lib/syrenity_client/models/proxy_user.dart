import 'package:syrenity_client_flutter/syrenity_client/client.dart';

class SyProxyUser {
  final SyrenityClient client;

  final int id;
  final String username;
  final String? avatar;
  final int? ownerId;
  final DateTime createdAt;

  SyProxyUser(
    this.client, {
    required this.id,
    required this.username,
    required this.avatar,
    required this.ownerId,
    required this.createdAt,
  });

  factory SyProxyUser.build(SyrenityClient client, Map<String, dynamic> json) {
    return SyProxyUser(
      client,
      id: json['id'] as int,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
      ownerId: json['owner_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
