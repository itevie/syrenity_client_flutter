import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:syrenity_client_flutter/syrenity_client/client.dart';

class SyHttpException implements Exception {
  final dynamic base;
  SyHttpException(this.base);

  @override
  String toString() {
    return base.toString();
  }
}

class HttpClient {
  final SyrenityClient client;

  HttpClient(this.client);

  Future<T> get<T, X>(
    String url,
    T Function(SyrenityClient client, X)? decode,
  ) async {
    final result = await http.get(
      Uri.parse("${client.baseUrl}$url"),
      headers: {'Authorization': "Token ${client.token}"},
    );

    if (result.statusCode != 200) {
      throw SyHttpException(result.body);
    }

    final dynamic body = jsonDecode(result.body);

    if (decode == null) {
      return body as T;
    }

    return decode(client, body as X);
  }

  Future<http.Response> rawPost(
    String url,
    Object? jsonBody, {
    Map<String, String> headers = const {},
  }) async {
    return await http.post(
      Uri.parse("${client.baseUrl}$url"),
      headers: headers,
      body: jsonBody,
    );
  }

  Future<T> post<T, X>(
    String url,
    Object? jsonBody,
    T Function(SyrenityClient client, X)? decode,
  ) async {
    final result = await http.post(
      Uri.parse("${client.baseUrl}$url"),
      headers: {
        'Authorization': "Token ${client.token}",
        'Content-Type': "application/json",
      },
      body: jsonBody,
    );

    if (result.statusCode != 200) {
      throw SyHttpException(result.body);
    }

    final dynamic body = jsonDecode(result.body);

    if (decode == null) {
      return body as T;
    }

    return decode(client, body as X);
  }
}
