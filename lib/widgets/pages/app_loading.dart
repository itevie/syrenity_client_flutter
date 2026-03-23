import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/main.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/pages/login.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

late void Function() reload;

class PreMainApp extends StatefulWidget {
  const PreMainApp({super.key});

  @override
  State<PreMainApp> createState() => _PreMainAppState();
}

class _PreMainAppState extends State<PreMainApp> {
  String? token;
  bool loading = true;
  bool failure = false;
  Function(String?)? disconnectEvent;

  @override
  void initState() {
    super.initState();

    reload = () {
      setState(() {
        token = null;
        loading = false;
      });
    };

    disconnectEvent = (reason) async {
      setState(() {
        loading = true;
      });

      while (true) {
        await Future.delayed(Duration(seconds: 2));
        final result = await _checkToken();
        if (result) break;
      }
    };

    client.events.on(SyEvents.disconnect, disconnectEvent!);

    _checkToken();
  }

  @override
  void dispose() {
    super.dispose();

    if (disconnectEvent != null) {
      client.events.off(SyEvents.disconnect, disconnectEvent!);
      disconnectEvent = null;
    }
  }

  Future<bool> _checkToken() async {
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

        return true;
      } catch (e) {
        return false;
      }
    }

    setState(() {
      loading = false;
    });

    return false;
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text("Connecting..."),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    loading = false;
                    token = null;
                  });
                },
                label: const Text("Logout"),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ),
      );
    }

    if (token == null) {
      return LoginPage(onLogin: _onLogin);
    }

    return const MainApp();
  }
}
