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

void main() async {
  client = SyrenityClient(
    baseUrl: "http://localhost:3000",
    websocketUrl: "ws://localhost:3000/ws",
  );

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

  // await client.login("MzM=.1760283952029.205fb667-4277-421f-9542-a2c4e380e301");

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

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();

    client.ws.messages.listen((data) {
      setState(() {
        messages.add(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: SyrenityTheme.serverChannelBarWidth,
          color: colors.secondaryContainer,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Servers
                    SizedBox(
                      width: SyrenityTheme.serverBarWidth,
                      child: ServerBar(),
                    ),
                    SizedBox(
                      width:
                          SyrenityTheme.serverChannelBarWidth -
                          SyrenityTheme.serverBarWidth,
                      child: ChannelBar(),
                    ),
                  ],
                ),
              ),
              SelfSection(),
            ],
          ),
        ),
        Expanded(child: MainRight()),
      ],
    );
  }
}
