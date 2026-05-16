import 'package:dawn_ui_flutter/dawn_ui.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/fullscreen_image_viewer.dart';

class MessageImage extends StatefulWidget {
  final String url;
  final List<String> allImages;

  const MessageImage({super.key, required this.url, this.allImages = const []});

  @override
  State<MessageImage> createState() => _MessageImageState();
}

class _MessageImageState extends State<MessageImage>
    with AutomaticKeepAliveClientMixin {
  static final Map<String, bool> _validated = {};

  bool loading = true;
  bool isImage = false;

  late final String safeUrl;

  @override
  void initState() {
    super.initState();

    safeUrl = client.fileBase.from(widget.url);

    _validate();
  }

  Future<void> _validate() async {
    // already validated before
    if (_validated.containsKey(safeUrl)) {
      isImage = _validated[safeUrl]!;

      setState(() {
        loading = false;
      });

      return;
    }

    try {
      final response = await http.head(Uri.parse(safeUrl));

      final contentType = response.headers["content-type"]?.toLowerCase() ?? "";

      final valid = contentType.startsWith("image/");

      _validated[safeUrl] = valid;

      if (!mounted) return;

      setState(() {
        isImage = valid;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        isImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (loading) {
      return const SizedBox(
        width: 100,
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isImage) {
      return const SizedBox.shrink();
    }

    return ContextMenu(
      onPressed: () {
        navigate(
          context,
          FullscreenImageViewer(
            imageUrls:
                widget.allImages.isNotEmpty ? widget.allImages : [widget.url],
            initialIndex:
                widget.allImages.contains(widget.url)
                    ? widget.allImages.indexOf(widget.url)
                    : 0,
          ),
        );
      },
      items:
          () => [makeCopyContextMenuButton(context, "Media Link", widget.url)],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          safeUrl,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return const SizedBox(
              width: 200,
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
