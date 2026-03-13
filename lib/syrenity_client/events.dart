import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';
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

class CreateUserClass extends SyEvent<SyUser> {
  const CreateUserClass() : super("create_user_class");
}

class CreateServerClass extends SyEvent<SyServer> {
  const CreateServerClass() : super("create_server_class");
}

class CreateChannelClass extends SyEvent<SyChannel> {
  const CreateChannelClass() : super("create_channel_class");
}

class MessageCreateEvent extends SyEvent<SyMessage> {
  const MessageCreateEvent() : super("messageCreate");
}

class SyEvents {
  static final ready = ReadyEvent();
  static final debug = DebugEvent();
  static final createUser = CreateUserClass();
  static final createChannel = CreateChannelClass();
  static final createServer = CreateServerClass();
}

class SyEventEmitter {
  final SyrenityClient client;

  SyEventEmitter(this.client);

  final Map<String, List<Function>> _listeners = {};

  void on<T>(SyEvent<T> event, void Function(T data) callback) {
    _listeners.putIfAbsent(event.name, () => []);
    _listeners[event.name]!.add(callback);
  }

  void emit<T>(SyEvent<T> event, T data) {
    final listeners = _listeners[event.name];
    if (listeners == null) return;

    for (final listener in listeners) {
      (listener as void Function(T))(data);
    }
  }
}
