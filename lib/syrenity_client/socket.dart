import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/dispatch_messages.dart';
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

      case WsMsgDispatch(
        guildId: final _,
        channelId: final _,
        type: final type,
        originalPayload: final _,
        payload: final payload,
      ):
        switch (payload) {
          case DispatchMessageCreate(message: final message):
            client.events.emit(SyEvents.dispatchCreateMessage, message);
            break;

          case DispatchMessageDelete(messageId: final messageId):
            client.events.emit(SyEvents.dispatchDeleteMessage, messageId);
            break;

          case DispatchChannelStartTyping(channelId: _, userId: _):
            client.events.emit(SyEvents.dispatchChannelStartTyping, payload);
            break;

          case DispatchUserStatusUpdate(status: final status):
            client.events.emit(SyEvents.dispatchUserStatusUpdate, status);
            break;

          // ignore: unreachable_switch_default
          default:
            client.events.emit(
              SyEvents.debug,
              "Dispatch was ignored due to not being implemented: $type",
            );
        }

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
