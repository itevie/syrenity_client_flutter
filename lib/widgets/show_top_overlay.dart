import 'package:flutter/material.dart';

void showTopOverlay(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  late OverlayEntry entry;
  bool visible = false;
  bool initialized = false;
  bool dismissed = false;

  void hide() {
    if (dismissed) return;
    dismissed = true;

    visible = false;
    entry.markNeedsBuild();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  entry = OverlayEntry(
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (!initialized) {
            initialized = true;
            Future.microtask(() => setState(() => visible = true));
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topRight,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                offset: visible ? Offset.zero : const Offset(0.3, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: visible ? 1 : 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      hoverColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      onTap: hide,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(blurRadius: 6, color: Colors.black26),
                          ],
                        ),
                        child: Text(message),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 2), hide);
}
