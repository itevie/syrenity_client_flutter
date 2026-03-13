import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';

class ChannelManager {
  final SyrenityClient client;

  ChannelManager(this.client);

  Future<List<SyChannel>> fetchChannelsForServer(int serverId) async {
    return await client.http.get<List<SyChannel>, List<dynamic>>(
      "/api/servers/$serverId/channels",
      (c, data) {
        return data
            .map((x) => SyChannel.build(c, x as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
