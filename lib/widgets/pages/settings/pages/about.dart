import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(client.fileBase.badUrl),
        const Text(
          "Syrenity",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
        const Text("Flutter Client"),
        Spacer(),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.code),
          label: const Text("GitHub"),
        ),
      ],
    );
  }
}
