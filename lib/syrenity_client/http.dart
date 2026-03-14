import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';

class SyHttpException implements Exception {
  final dynamic base;
  final SyrenityClient client;
  SyHttpException(this.base, this.client) {
    client.events.emit(SyEvents.error, this);
  }

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
    client.debug("HTTP Get: $url");

    final result = await http.get(
      Uri.parse("${client.baseUrl}$url"),
      headers: {'Authorization': "Token ${client.token}"},
    );

    if (result.statusCode != 200) {
      throw SyHttpException(result.body, client);
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
    client.debug("HTTP Raw Post: $url");

    return await http.post(
      Uri.parse("${client.baseUrl}$url"),
      headers: headers,
      body: jsonBody,
    );
  }

  Future<http.Response> rawDelete(
    String url,
    Object? jsonBody, {
    Map<String, String> headers = const {},
  }) async {
    client.debug("HTTP Raw Delete: $url");

    final response = await http.delete(
      Uri.parse("${client.baseUrl}$url"),
      headers: {'Authorization': "Token ${client.token}", ...headers},
      body: jsonBody,
    );

    if (response.statusCode != 200) {
      throw SyHttpException(response.body, client);
    }

    return response;
  }

  Future<http.Response> delete(
    String url,
    Object? jsonBody, {
    Map<String, String> headers = const {},
  }) async {
    client.debug("HTTP Delete: $url");

    return await http.delete(
      Uri.parse("${client.baseUrl}$url"),
      headers: {
        'Authorization': "Token ${client.token}",
        'Content-Type': "application/json",
        ...headers,
      },
      body: jsonBody,
    );
  }

  Future<T> post<T, X>(
    String url,
    Object? jsonBody,
    T Function(SyrenityClient client, X)? decode,
  ) async {
    client.debug("HTTP Post: $url");

    final result = await http.post(
      Uri.parse("${client.baseUrl}$url"),
      headers: {
        'Authorization': "Token ${client.token}",
        'Content-Type': "application/json",
      },
      body: jsonEncode(jsonBody),
    );

    if (result.statusCode != 200) {
      throw SyHttpException(result.body, client);
    }

    final dynamic body = jsonDecode(result.body);

    if (decode == null) {
      return body as T;
    }

    return decode(client, body as X);
  }
}
