import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/dispatch_messages.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/custom_status.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/message.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/user.dart';

abstract class SyEvent<T> {
  final String name;
  const SyEvent(this.name);
}

class ReadyEvent extends SyEvent<SyUser> {
  const ReadyEvent() : super("ready");
}

class DebugEvent extends SyEvent<String> {
  const DebugEvent() : super("debug");
}

class ErrorEvent extends SyEvent<Exception> {
  const ErrorEvent() : super("error");
}

class CreateUserClass extends SyEvent<SyUser> {
  const CreateUserClass() : super("create_user_class");
}

class CreateServerClass extends SyEvent<SyServer> {
  const CreateServerClass() : super("create_server_class");
}

class CreateChannelClass extends SyEvent<SyChannel> {
  const CreateChannelClass() : super("create_channel_class");
}

class CreateCustomClass extends SyEvent<SyCustomStatus> {
  const CreateCustomClass() : super("create_custom_status");
}

// Dispatches
class EvDispatchMessageCreate extends SyEvent<SyMessage> {
  const EvDispatchMessageCreate() : super("dispatch_message_create");
}

class EvDispatchMessageDelete extends SyEvent<int> {
  const EvDispatchMessageDelete() : super("dispatch_message_delete");
}

class EvDispatchUserStatusUpdate extends SyEvent<SyCustomStatus> {
  const EvDispatchUserStatusUpdate() : super("dispatch_user_status_update");
}

class EvDispatchChannelStartTyping extends SyEvent<DispatchChannelStartTyping> {
  const EvDispatchChannelStartTyping() : super("dispatch_channel_start_Typing");
}

class SyEvents {
  static final ready = ReadyEvent();
  static final debug = DebugEvent();
  static final error = ErrorEvent();
  static final createUser = CreateUserClass();
  static final createChannel = CreateChannelClass();
  static final createServer = CreateServerClass();
  static final createCustomStatus = CreateCustomClass();

  static final dispatchUserStatusUpdate = EvDispatchUserStatusUpdate();

  static final dispatchCreateMessage = EvDispatchMessageCreate();
  static final dispatchDeleteMessage = EvDispatchMessageDelete();
  static final dispatchChannelStartTyping = EvDispatchChannelStartTyping();
}

class SyEventEmitter {
  final SyrenityClient client;

  SyEventEmitter(this.client);

  final Map<String, List<Function>> _listeners = {};

  void on<T>(SyEvent<T> event, void Function(T data) callback) {
    _listeners.putIfAbsent(event.name, () => []);
    _listeners[event.name]!.add(callback);
  }

  void off<T>(SyEvent<T> event, void Function(T data) callback) {
    final listeners = _listeners[event.name];
    if (listeners == null) return;

    listeners.remove(callback);

    if (listeners.isEmpty) {
      _listeners.remove(event.name);
    }
  }

  void emit<T>(SyEvent<T> event, T data) {
    final listeners = _listeners[event.name];
    if (listeners == null) return;

    for (final listener in listeners) {
      (listener as void Function(T))(data);
    }
  }
}
