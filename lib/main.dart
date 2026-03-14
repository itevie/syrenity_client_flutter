import 'package:dawn_ui_flutter/prompts/prompts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';
import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/pages/login.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/main_right.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/self_section.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/server_bar.dart';

late SyrenityClient client;
bool ready = false;

final String defaultBaseApiUrl = "http://localhost:3000";

Future<void> setupClient({bool login = true}) async {
  final prefs = await SharedPreferences.getInstance();
  final storedbaseApiUrl = prefs.getString("base_api_url") ?? defaultBaseApiUrl;

  client = SyrenityClient(
    baseUrl: storedbaseApiUrl,
    websocketUrl:
        "${storedbaseApiUrl.startsWith("https://") ? "wss" : "ws"}://${storedbaseApiUrl.replaceFirst("http://", "").replaceAll("https://", "")}/ws",
  );

  if (login == false) return;

  client.events.on(SyEvents.ready, (user) {
    userStore.set(user);
    ready = true;
  });

  client.events.on(SyEvents.debug, (message) {
    print(message);
  });

  client.events.on(SyEvents.createChannel, (channel) {
    channelStore.set(channel);
  });

  client.events.on(SyEvents.createServer, (server) {
    serverStore.set(server);
  });

  client.events.on(SyEvents.createUser, (user) {
    userStore.set(user);
  });

  client.events.on(SyEvents.error, (error) {
    print(error);
    showError!(error);
  });
}

void main() async {
  await setupClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => currentSettingsStore),
        ChangeNotifierProvider(create: (_) => userStore),
        ChangeNotifierProvider(create: (_) => channelStore),
        ChangeNotifierProvider(create: (_) => serverStore),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),

        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
        home: PreMainApp(),
      ),
    ),
  );
}

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
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString("token");

    if (storedToken != null) {
      try {
        await client.login(storedToken);

        setState(() {
          token = storedToken;
          loading = false;
        });

        return;
      } catch (e) {
        await prefs.remove("token");
      }
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _onLogin(String newToken) async {
    final prefs = await SharedPreferences.getInstance();

    await setupClient();
    await prefs.setString("token", newToken);

    await client.login(newToken, noWs: true);

    setState(() {
      token = newToken;
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syrenity',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      home: Scaffold(
        // appBar: AppBar(title: const Text("Syrenity")),
        body: ChatPage(),
      ),
    );
  }
}

void Function(bool?)? setDrawerVisibility;
late void Function(Exception)? showError;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool drawerShown = false;

  @override
  void initState() {
    setDrawerVisibility = (value) {
      setState(() {
        if (value == null) {
          drawerShown = !drawerShown;
        } else {
          drawerShown = value;
        }
      });
    };

    showError = (error) {
      showErrorPrompt(context, error.toString());
    };
    super.initState();
  }

  @override
  void dispose() {
    setDrawerVisibility = null;
    showError = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    bool showMobileDrawer = !isDesktop && drawerShown;

    return GestureDetector(
      // Detect horizontal swipes anywhere on the screen
      onHorizontalDragUpdate: (details) {
        if (!isDesktop) {
          if (details.delta.dx > 10) {
            // Swipe right → open drawer
            setState(() => drawerShown = true);
          } else if (details.delta.dx < -10) {
            // Swipe left → close drawer
            setState(() => drawerShown = false);
          }
        }
      },
      child: Row(
        children: [
          // Server/Channel panel
          Offstage(
            offstage: !(isDesktop || drawerShown),
            child: Container(
              width:
                  showMobileDrawer
                      ? MediaQuery.of(context).size.width
                      : SyrenityTheme.serverChannelBarWidth,
              color: colors.secondaryContainer,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Servers (keeps state alive)
                        SizedBox(
                          width: SyrenityTheme.serverBarWidth,
                          child: ServerBar(),
                        ),
                        // Channels (keeps state alive)
                        Expanded(child: ChannelBar()),
                      ],
                    ),
                  ),
                  SelfSection(),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(child: MainRight()),
        ],
      ),
    );
  }
}
