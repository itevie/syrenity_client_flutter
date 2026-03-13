import 'dart:convert';

import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/syrenity_client/http.dart';
import 'package:syrenity_client_flutter/syrenity_client/managers/channel_manager.dart';
import 'package:syrenity_client_flutter/syrenity_client/managers/server_manager.dart';
import 'package:syrenity_client_flutter/syrenity_client/managers/user_manager.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/file_base.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/user.dart';
import 'package:syrenity_client_flutter/syrenity_client/socket.dart';

class SyrenityClient {
  final String baseUrl;
  final String websocketUrl;

  late final HttpClient http = HttpClient(this);
  late final UserManager users = UserManager(this);
  late final ChannelManager channels = ChannelManager(this);
  late final ServerManager servers = ServerManager(this);
  late final SyFileBase fileBase = SyFileBase(
    this,
    badUrl: "$baseUrl/public/logo192.png",
  );
  late final SyEventEmitter events = SyEventEmitter(this);
  late final SyWebsocketManager ws = SyWebsocketManager(this);

  String? token;
  SyUser? _user;

  SyUser get user {
    if (_user == null) {
      throw "Client user has not been initialised yet";
    }

    return _user!;
  }

  SyUser? get scaryUser {
    return _user;
  }

  set user(SyUser user) {
    _user = user;
  }

  SyrenityClient({required this.baseUrl, required this.websocketUrl});

  void setToken(String token) {
    this.token = token;
  }

  Future<String> fetchSession(String email, String password) async {
    final response = await http.rawPost(
      "/auth/password",
      '{"username":"$email","password":"$password"}',
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Login failed");
    }

    final cookie = response.headers['set-cookie'];

    if (cookie == null) {
      throw Exception("No session cookie returned");
    }

    // Extract connect.sid
    final session = cookie.split(';').first;

    return await _getToken(session);
  }

  Future<String> _getToken(String session) async {
    final response = await http.rawPost(
      "/auth/get-token",
      null,
      headers: {"Cookie": session, "Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to get token (${response.statusCode})");
    }

    final json = jsonDecode(response.body);

    return json['token'];
  }

  Future<void> login(String token, {bool noWs = false}) async {
    this.token = token;

    if (noWs) {
      debug("Logging in without ws");
      _user = await getUser();
    } else {
      debug("Logging in with ws");
      await ws.connect();
    }
  }

  Future<bool> checkConnected() async {
    try {
      await http.get("/api/ping", null);
      debug("Check connected success");
      return true;
    } catch (e) {
      debug("Check connected failure");
      return false;
    }
  }

  Future<SyUser> getUser() async {
    return await http.get("/api/users/@me", SyUser.build);
  }

  void debug(String message) {
    events.emit(SyEvents.debug, message);
  }
}
