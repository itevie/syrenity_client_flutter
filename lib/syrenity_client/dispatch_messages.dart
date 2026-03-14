import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/message.dart';
import 'package:syrenity_client_flutter/syrenity_client/ws_messages.dart';

sealed class DispatchMessage {
  const DispatchMessage();

  factory DispatchMessage.fromJson(
    WsMsgDispatch dispatch,
    SyrenityClient client,
  ) {
    switch (dispatch.type) {
      case "MessageCreate":
        return DispatchMessageCreate(
          message: SyMessage.build(client, dispatch.originalPayload['message']),
        );

      case "ChannelStartTyping":
        return DispatchChannelStartTyping(
          channelId: dispatch.originalPayload['channel_id'],
          userId: dispatch.originalPayload['user_id'],
        );
      default:
        throw Exception("Unknown dispatch type: ${dispatch.type}");
    }
  }
}

class DispatchMessageCreate extends DispatchMessage {
  final SyMessage message;

  const DispatchMessageCreate({required this.message});
}

class DispatchChannelStartTyping extends DispatchMessage {
  final int channelId;
  final int userId;

  const DispatchChannelStartTyping({
    required this.channelId,
    required this.userId,
  });
}
