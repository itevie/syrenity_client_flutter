import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/syrenity_client/ws_messages.dart';

class SyWebsocketManager {
  final SyrenityClient client;

  SyWebsocketManager(this.client);

  late WebSocket socket;

  final StreamController<String> _messages = StreamController.broadcast();

  Stream<String> get messages => _messages.stream;

  Future<void> connect() async {
    socket = await WebSocket.connect(client.websocketUrl);
    socket.listen((data) {
      _messages.add(data);
      client.debug("Received WS: $data");
      final message = WsMessage.fromJson(jsonDecode(data), client);
      handleMessage(message);
    });
  }

  void handleMessage(WsMessage message) async {
    switch (message) {
      case WsMsgIdentify(token: final _):
        break;
      case WsMsgAuthenticate():
        final payload = WsMsgIdentify(token: client.token!);

        send(jsonEncode(payload.toJson()));
        break;
      case WsMsgError(error: final _):
        break;

      case WsMsgHello(user: final user):
        client.user = user;
        client.events.emit(SyEvents.ready, user);
        break;

      case WsMsgHeartbeat():
        send(jsonEncode(WsMsgHeartbeat()));
        break;
    }
  }

  void send(String message) {
    socket.add(message);
  }

  void dispose() {
    socket.close();
    _messages.close();
  }
}
