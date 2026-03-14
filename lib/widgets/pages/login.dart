import 'package:dawn_ui_flutter/prompts/prompts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syrenity_client_flutter/main.dart';

class LoginPage extends StatefulWidget {
  final Future<void> Function(String token) onLogin;

  const LoginPage({super.key, required this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String server = "Loading...";
  String? imageUrl;

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    loadServer();
  }

  void loadServer() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString("base_api_url");

    setState(() {
      server = value ?? defaultBaseApiUrl;
      imageUrl = "$value/public/logo192.png";
    });
  }

  void login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    final response = await client.fetchSession(username, password);

    await widget.onLogin(response);
  }

  void forgotPassword() async {
    print("Forgot password clicked");
  }

  void changeServer() async {
    final server = await showInputPrompt(
      context,
      const Text("Enter server url (with http/https)"),
      null,
    );

    if (server == null) return;

    void error(String? error) async {
      return await showMessagePrompt(
        // ignore: use_build_context_synchronously
        context,
        const Text("Server Error"),
        Text(
          "Failed to ping the server provided, did you put it in correctly? You put: $server ${error == null ? "" : "The error was $error"}",
        ),
      );
    }

    try {
      final response = await http.get(Uri.parse("$server/api/ping"));

      if (response.statusCode != 200) return error(null);
    } catch (e) {
      return error(e.toString());
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("base_api_url", server);

    loadServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl != null) Image.network(imageUrl!, width: 100),

                // const Text(
                //   "Login",
                //   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                // ),
                const SizedBox(height: 32),

                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username or Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    TextButton(
                      onPressed: changeServer,
                      child: const Text("Change Server"),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: forgotPassword,
                      child: const Text("Forgot password?"),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Server: $server",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
