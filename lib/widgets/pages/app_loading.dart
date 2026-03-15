import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/main.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/widgets/pages/login.dart';

late void Function() reload;

class PreMainApp extends StatefulWidget {
  const PreMainApp({super.key});

  @override
  State<PreMainApp> createState() => _PreMainAppState();
}

class _PreMainAppState extends State<PreMainApp> {
  String? token;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    reload = () {
      setState(() {
        token = null;
        loading = false;
      });
    };

    _checkToken();
  }

  Future<void> _checkToken() async {
    final storedToken = SettingsStorage.instance.get<String>("token");

    if (storedToken != null) {
      try {
        await client.login(storedToken);

        client.events.on(SyEvents.ready, (_) {
          setState(() {
            token = storedToken;
            loading = false;
          });
        });

        return;
      } catch (e) {
        await SettingsStorage.instance.remove("token");
      }
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _onLogin(String newToken) async {
    await setupClient();
    SettingsStorage.instance.set("token", newToken);

    await client.login(newToken, noWs: true);

    client.events.on(SyEvents.ready, (_) {
      setState(() {
        token = newToken;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (token == null) {
      return LoginPage(onLogin: _onLogin);
    }

    return const MainApp();
  }
}
