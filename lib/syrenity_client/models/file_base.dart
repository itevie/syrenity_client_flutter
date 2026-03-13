import 'package:syrenity_client_flutter/syrenity_client/client.dart';

class SyFileBase {
  final SyrenityClient client;
  final String badUrl;

  SyFileBase(this.client, {required this.badUrl});

  String? from(String? url) {
    if (url == null) return badUrl;

    if (RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(url)) {
      return "${client.baseUrl}/files/$url";
    } else if (url.startsWith("http://")) {
      return url;
    } else {
      return badUrl;
    }
  }
}
