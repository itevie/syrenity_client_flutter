import 'package:flutter/material.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

Widget channelName(SyChannel c) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      c.type == SyChannelType.todo
          ? const Icon(Icons.task)
          : const Icon(Icons.tag),
      Text(c.name),
    ],
  );
}
