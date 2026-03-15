import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/syrenity_client/managers/server_channels_manager.dart';
import 'package:syrenity_client_flutter/syrenity_client/managers/server_invites_manager.dart';
import 'package:syrenity_client_flutter/syrenity_client/managers/server_membert_manager.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/user.dart';

class SyServer {
  final SyrenityClient client;

  final int id;
  final String name;
  final int ownerId;
  final String? description;
  final String? avatar;

  late final ServerChannelsManager channels = ServerChannelsManager(
    client: client,
    server: this,
  );

  late final ServerInvitesManager invites = ServerInvitesManager(
    client: client,
    server: this,
  );

  late final ServerMembertManager members = ServerMembertManager(
    client: client,
    server: this,
  );

  SyServer(
    this.client, {
    required this.id,
    required this.name,
    required this.ownerId,
    required this.description,
    required this.avatar,
  });

  factory SyServer.build(SyrenityClient client, Map<String, dynamic> json) {
    final server = SyServer(
      client,
      id: json['id'] as int,
      name: json['name'] as String,
      ownerId: json['owner_id'] as int,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
    );

    client.events.emit(SyEvents.createServer, server);

    return server;
  }

  Future<SyUser> fetchOwner() async {
    return await client.users.fetch(ownerId);
  }

  Future<List<SyChannel>> fetchChannels() async {
    return await client.channels.fetchChannelsForServer(id);
  }
}
