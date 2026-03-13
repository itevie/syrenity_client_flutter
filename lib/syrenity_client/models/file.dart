import 'package:syrenity_client_flutter/syrenity_client/client.dart';

class SyFile {
  final SyrenityClient client;

  final String id;
  final DateTime createdAt;
  final String fileName;
  final String? originalUrl;

  SyFile(
    this.client, {
    required this.id,
    required this.createdAt,
    required this.fileName,
    required this.originalUrl,
  });

  factory SyFile.build(SyrenityClient client, Map<String, dynamic> json) {
    return SyFile(
      client,
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      fileName: json['file_name'] as String,
      originalUrl: json['original_url'] as String?,
    );
  }
}
