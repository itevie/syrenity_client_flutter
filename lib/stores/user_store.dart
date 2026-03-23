import 'package:flutter/material.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class UserStore extends ChangeNotifier {
  final Map<int, SyUser> _users = {};

  SyUser? operator [](int id) => _users[id];

  void set(SyUser user) {
    _users[user.id] = user;
    notifyListeners();
  }

  void remove(int id) {
    _users.remove(id);
    notifyListeners();
  }

  Iterable<SyUser> get all => _users.values;
}

final userStore = UserStore();
