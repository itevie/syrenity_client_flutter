import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/base.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/text_channel.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/todo_channel.dart';

class AllChannels extends StatelessWidget {
  final int? channelId;

  const AllChannels({super.key, this.channelId});

  @override
  Widget build(BuildContext context) {
    
    if (channelId == null) {
      return BaseMainRight(channelId: channelId, content: null);
    }

    final channel = context.read<ChannelStore>()[channelId!];

    if (channel!.isTextChannel()) {
      return TextChannel(channelId: channel.id);
    } else if (channel.isTodoChannel()) {
      return TodoChannel(channelId: channel.id);
    }

    return SizedBox();
  }
}
