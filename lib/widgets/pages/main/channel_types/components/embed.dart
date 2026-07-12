import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/components/message.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class Embed extends StatelessWidget {
  final SyEmbed embed;
  const Embed(this.embed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,

      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Color((embed.colour ?? 0x666666) | 0xFF000000),
            width: 4,
          ),
        ),
      ),
      child: Card(
        elevation: 10,
        child: Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (embed.title != null)
                      Row(
                        children: [
                          if (embed.title != null)
                            Text(
                              embed.title!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),

                    if (embed.description != null) ...[
                      const SizedBox(height: 4),
                      Text(embed.description!, softWrap: true),
                    ],

                    if (embed.imageFile != null) ...[
                      const SizedBox(height: 4),

                      SizedBox(
                        width: 128,
                        height: 128,
                        child: Image.network(
                          client.fileBase.from(embed.imageFile),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],

                    if (embed.footerText != null ||
                        embed.timestamp != null) ...[
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          if (embed.footerText != null)
                            Text(
                              embed.footerText!,
                              style: TextStyle(fontSize: 10),
                            ),
                          if (embed.footerText != null &&
                              embed.timestamp != null) ...[
                            const SizedBox(width: 4),
                            const Text("-", style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 4),
                          ],
                          if (embed.timestamp != null)
                            Text(
                              formatMessageDate(embed.timestamp!),
                              style: const TextStyle(fontSize: 10),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              if (embed.thumbnailFile != null) ...[
                const SizedBox(width: 8),

                SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.network(
                    client.fileBase.from(embed.thumbnailFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
