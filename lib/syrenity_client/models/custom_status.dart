import 'package:syrenity_client_flutter/syrenity_client/client.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';

class SyCustomStatus {
  final SyrenityClient client;

  final int userId;
  final String? visibility;
  final String? device;
  final String? statusText;
  final DateTime? expiresAt;
  final DateTime? lastSeen;

  SyCustomStatus(
    this.client, {
    required this.userId,
    required this.visibility,
    required this.device,
    required this.statusText,
    required this.expiresAt,
    required this.lastSeen,
  });

  factory SyCustomStatus.build(
    SyrenityClient client,
    Map<String, dynamic> json,
  ) {
    final status = SyCustomStatus(
      client,
      userId: json['user_id'] as int,
      visibility: json['visibility'] as String?,
      device: json['device'] as String?,
      statusText: json['status_text'] as String?,
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'] as String)
              : null,
      lastSeen:
          json['last_seen'] != null
              ? DateTime.parse(json['last_seen'] as String)
              : null,
    );

    client.events.emit(SyEvents.createCustomStatus, status);

    return status;
  }
}
