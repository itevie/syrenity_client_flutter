import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/dispatch_messages.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/user.dart';

sealed class WsMessage {
  const WsMessage();

  Map<String, dynamic> toJson();

  factory WsMessage.fromJson(Map<String, dynamic> json, SyrenityClient client) {
    switch (json["type"]) {
      case "Identify":
        return WsMsgIdentify(token: json["payload"]["token"] as String);

      case "Authenticate":
        return WsMsgAuthenticate();

      case "Heartbeat":
        return WsMsgHeartbeat();

      case "Hello":
        return WsMsgHello(user: SyUser.build(client, json["payload"]["user"]));

      case "Error":
        return WsMsgError(error: json["payload"]["error"] as String);

      case "Dispatch":
        return WsMsgDispatch(
          client: client,
          guildId: json['payload']['guildId'],
          channelId: json['payload']['channelId'],
          type: json['payload']['type'],
          originalPayload: json['payload']['payload'],
        );

      default:
        throw Exception("Unknown message type: ${json["type"]}: $json");
    }
  }
}

class WsMsgDispatch extends WsMessage {
  final SyrenityClient client;

  final int? guildId;
  final int? channelId;
  final String type;
  final Map<String, dynamic> originalPayload;
  late DispatchMessage payload;

  WsMsgDispatch({
    required this.client,
    required this.guildId,
    required this.channelId,
    required this.type,
    required this.originalPayload,
  }) {
    payload = DispatchMessage.fromJson(this, client);
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class WsMsgHello extends WsMessage {
  final SyUser user;

  const WsMsgHello({required this.user});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class WsMsgError extends WsMessage {
  final String error;

  const WsMsgError({required this.error});

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class WsMsgIdentify extends WsMessage {
  final String token;

  const WsMsgIdentify({required this.token});

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Identify",
      "payload": {"token": token},
    };
  }
}

class WsMsgAuthenticate extends WsMessage {
  const WsMsgAuthenticate();

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}

class WsMsgHeartbeat extends WsMessage {
  const WsMsgHeartbeat();

  @override
  Map<String, dynamic> toJson() {
    return {"type": "Heartbeat"};
  }
}
