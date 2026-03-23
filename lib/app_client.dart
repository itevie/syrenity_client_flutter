import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/custom_status_store.dart';
import 'package:syrenity_client_flutter/stores/member_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

late SyrenityClient client;
bool ready = false;

final String defaultBaseApiUrl = "http://localhost:3000";

Future<void> setupClient({bool login = true}) async {
  final storedbaseApiUrl =
      SettingsStorage.instance.get<String>("base_api_url") ?? defaultBaseApiUrl;

  client = SyrenityClient(
    baseUrl: storedbaseApiUrl,
    websocketUrl:
        "${storedbaseApiUrl.startsWith("https://") ? "wss" : "ws"}://${storedbaseApiUrl.replaceFirst("http://", "").replaceAll("https://", "")}/ws",
  );

  if (login == false) return;

  client.events.on(SyEvents.ready, (user) {
    userStore.set(user);
    ready = true;
  });

  client.events.on(SyEvents.debug, (message) {
    print(message);
  });

  client.events.on(SyEvents.createChannel, (channel) {
    channelStore.set(channel);
  });

  client.events.on(SyEvents.createServer, (server) {
    serverStore.set(server);
  });

  client.events.on(SyEvents.createUser, (user) {
    userStore.set(user);
  });

  client.events.on(SyEvents.createMemberClass, (member) {
    memberStore.set(member);
  });

  client.events.on(SyEvents.error, (error) {
    MainCallbacks.showError!(error);
  });

  client.events.on(SyEvents.dispatchUserStatusUpdate, (status) {
    customStatuStore.set(status);
  });

  client.events.on(SyEvents.createCustomStatus, (status) {
    customStatuStore.set(status);
  });
}
