import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/custom_status_store.dart';
import 'package:syrenity_client_flutter/stores/member_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';
import 'package:syrenity_client_flutter/widgets/pages/app_loading.dart';
import 'package:syrenity_client_flutter/widgets/pages/shell/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsStorage.instance.init();
  await setupClient();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint("EXCEPTION:");
    debugPrint(details.exceptionAsString());

    debugPrint("STACK TRACE:");
    debugPrint(details.stack.toString());
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => currentSettingsStore),
        ChangeNotifierProvider(create: (_) => userStore),
        ChangeNotifierProvider(create: (_) => memberStore),
        ChangeNotifierProvider(create: (_) => channelStore),
        ChangeNotifierProvider(create: (_) => serverStore),
        ChangeNotifierProvider(create: (_) => customStatuStore),
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
        body: SafeArea(child: ChatPage()),
      ),
    );
  }
}
