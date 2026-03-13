import 'package:syrenity_client_flutter/syrenity_client/client.dart';

class SyFriendRequest {
  final SyrenityClient client;

  final int forUser;
  final int byUser;
  final DateTime createdAt;

  SyFriendRequest(
    this.client, {
    required this.forUser,
    required this.byUser,
    required this.createdAt,
  });

  factory SyFriendRequest.build(
    SyrenityClient client,
    Map<String, dynamic> json,
  ) {
    return SyFriendRequest(
      client,
      forUser: json['for_user'] as int,
      byUser: json['by_user'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
