import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/friend_request.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/relationship.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';

class SyUser {
  final SyrenityClient client;

  final int id;
  String username;
  final String? email;
  final bool? emailVerified;
  final String? avatar;
  final DateTime createdAt;
  final bool isBot;
  final String? bio;
  final String? profileBanner;

  SyUser(
    this.client, {
    required this.id,
    required this.username,
    required this.email,
    required this.emailVerified,
    required this.avatar,
    required this.createdAt,
    required this.isBot,
    required this.bio,
    required this.profileBanner,
  });

  factory SyUser.build(SyrenityClient client, Map<String, dynamic> json) {
    final user = SyUser(
      client,
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      emailVerified: json['email_verified'] as bool?,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isBot: json['is_bot'] as bool,
      bio: json['bio'] as String?,
      profileBanner: json['profile_banner'] as String?,
    );

    client.events.emit(SyEvents.createUser, user);

    return user;
  }

  Future<List<SyServer>> fetchServers() async {
    return await client.http.get<List<SyServer>, List<dynamic>>(
      "/api/users/${client.user.id}/servers",
      (c, data) {
        return data
            .map((x) => SyServer.build(c, x as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<SyRelationship>> fetchRelationships() async {
    return await client.http.get<List<SyRelationship>, List<dynamic>>(
      "/api/users/${client.user.id}/relationships",
      (c, data) {
        return data
            .map((x) => SyRelationship.build(c, x as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<SyFriendRequest>> fetchFriendRequests() async {
    return await client.http.get<List<SyFriendRequest>, List<dynamic>>(
      "/api/users/${client.user.id}/friend_requests",
      (c, data) {
        return data
            .map((x) => SyFriendRequest.build(c, x as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
