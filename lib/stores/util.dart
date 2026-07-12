import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/member_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

(SyMember, SyServer) getMemberFromChannelAndUser(
  BuildContext context,
  int channelId,
  SyUser user,
) {
  final memberStore = context.read<MemberStore>();
  final serverStore = context.read<ServerStore>();
  final channelStore = context.read<ChannelStore>();

  final server = serverStore[channelStore[channelId]!.guildId!];

  if (server == null) {
    throw "Server was null";
  }

  final member = memberStore.get(server.id, user.id);

  if (member == null) {
    throw "Member was null";
  }

  return (member, server);
}

SyMember getMemberFromServer(
  BuildContext context,
  SyServer server,
  SyUser user,
) {
  final memberStore = context.read<MemberStore>();

  final member = memberStore.get(server.id, user.id);

  if (member == null) {
    throw "Member was null";
  }

  return member;
}

SyServer? getCurrentServer(BuildContext context) {
  final settings = context.read<CurrentSettingsState>();

  if (settings.serverId == null) return null;

  final servers = context.read<ServerStore>();
  final server = servers[settings.serverId!];

  return server;
}
