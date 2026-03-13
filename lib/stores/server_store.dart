import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';

class ServerStore extends ChangeNotifier {
  final Map<int, SyServer> _servers = {};

  SyServer? operator [](int id) => _servers[id];

  void set(SyServer server) {
    _servers[server.id] = server;
    notifyListeners();
  }

  void remove(int id) {
    _servers.remove(id);
    notifyListeners();
  }

  Iterable<SyServer> get all => _servers.values;
}

final serverStore = ServerStore();
