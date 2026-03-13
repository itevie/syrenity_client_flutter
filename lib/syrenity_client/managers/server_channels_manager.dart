import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';

class ServerChannelsManager {
  final SyrenityClient client;
  final SyServer server;

  ServerChannelsManager({required this.client, required this.server});
}
