import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';
import 'package:syrenity_client_flutter/widgets/pages/app_loading.dart';
import 'package:syrenity_client_flutter/widgets/pages/chat_page.dart';

void main() async {
  await SettingsStorage.instance.init();
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syrenity',
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

      home: Scaffold(
        // appBar: AppBar(title: const Text("Syrenity")),
        body: ChatPage(),
      ),
    );
  }
}
