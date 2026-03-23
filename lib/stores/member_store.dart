import 'package:flutter/material.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class MemberStore extends ChangeNotifier {
  final Map<String, SyMember> _members = {};

  String _createString(int serverId, int memberId) {
    return "$serverId-$memberId";
  }

  SyMember? get(int serverId, int memberId) {
    return _members[_createString(serverId, memberId)];
  }

  void set(SyMember member) {
    _members[_createString(member.guildId, member.userId)] = member;
    notifyListeners();
  }

  void remove(int serverId, int memberId) {
    _members.remove(_createString(serverId, memberId));
    notifyListeners();
  }

  Iterable<SyMember> get all => _members.values;
}

final memberStore = MemberStore();
