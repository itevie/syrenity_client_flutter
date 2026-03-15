import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/member.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';

class ServerMembertManager {
  final SyrenityClient client;
  final SyServer server;

  ServerMembertManager({required this.client, required this.server});

  Future<List<SyMember>> fetchAll() async {
    return await client.http.get<List<SyMember>, List<dynamic>>(
      "/api/servers/${server.id}/members",
      (c, data) {
        return data
            .map((x) => SyMember.build(c, x as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
