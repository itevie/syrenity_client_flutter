import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';

class ServerManager {
  final SyrenityClient client;

  ServerManager(this.client);

  Future<List<SyServer>> fetchAll() async {
    return await client.http.get<List<SyServer>, List<dynamic>>(
      "/api/users/${client.user.id}/servers",
      (c, x) => x.map((v) => SyServer.build(client, v)).toList(),
    );
  }
}
