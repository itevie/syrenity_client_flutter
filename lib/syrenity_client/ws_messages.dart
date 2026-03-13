import 'package:syrenity_client_flutter/syrenity_client/client.dart';
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

      default:
        throw Exception("Unknown message type: ${json["type"]}: $json");
    }
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
