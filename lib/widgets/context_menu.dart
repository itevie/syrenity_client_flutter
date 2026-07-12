import 'package:flutter/material.dart';

sealed class ContextMenuItem {
  const ContextMenuItem();
}

class ContextMenuButton extends ContextMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool danger;

  const ContextMenuButton({
    required this.label,
    required this.onPressed,
    this.danger = false,
    this.icon,
  });
}

class ContextMenuSeparator extends ContextMenuItem {
  const ContextMenuSeparator();
}

class ContextMenu extends StatefulWidget {
  final Widget child;
  final List<ContextMenuItem> Function()? items;
  final Future<List<ContextMenuItem>> Function()? asyncItems;
  final bool onTapToo;
  final VoidCallback? onPressed;

  const ContextMenu({
    super.key,
    required this.child,
    this.items,
    this.asyncItems,
    this.onTapToo = false,
    this.onPressed,
  });

  @override
  State<StatefulWidget> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  Offset? _tapPosition;
  OverlayEntry? _loadingOverlay;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _showContextMenu(BuildContext context, Offset other) async {
    List<ContextMenuItem> items = [];

    if (widget.items != null) {
      items = widget.items!();
    } else if (widget.asyncItems != null) {
      _showLoading(context, other);
      items = await widget.asyncItems!();
      _hideLoading();
    }

    items = _normalizeSeparators(items);

    final position = _tapPosition ?? other;

    await showMenu(
      // ignore: use_build_context_synchronously
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: items.map((x) => buildMenuItem(x)).toList(),
    );
  }

  List<ContextMenuItem> _normalizeSeparators(List<ContextMenuItem> items) {
    final result = <ContextMenuItem>[];

    for (final item in items) {
      final isSeparator = item is ContextMenuSeparator;

      if (isSeparator) {
        // skip if previous is also separator
        if (result.isNotEmpty && result.last is ContextMenuSeparator) {
          continue;
        }
      }

      result.add(item);
    }

    // remove leading separator
    while (result.isNotEmpty && result.first is ContextMenuSeparator) {
      result.removeAt(0);
    }

    // remove trailing separator
    while (result.isNotEmpty && result.last is ContextMenuSeparator) {
      result.removeLast();
    }

    return result;
  }

  PopupMenuEntry buildMenuItem(ContextMenuItem item) {
    final colors = Theme.of(context).colorScheme;

    switch (item) {
      case ContextMenuButton(
        :final label,
        :final icon,
        :final onPressed,
        :final danger,
      ):
        return PopupMenuItem(
          onTap: onPressed,
          child: Row(
            children: [
              if (icon != null)
                Icon(icon, size: 16, color: danger ? colors.error : null),
              if (icon != null) const SizedBox(width: 8),
              Text(
                label,
                style: danger ? TextStyle(color: colors.error) : null,
              ),
            ],
          ),
        );

      case ContextMenuSeparator():
        return const PopupMenuDivider();
    }
  }

  void _showLoading(BuildContext context, Offset pos) {
    _loadingOverlay?.remove();

    _loadingOverlay = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: const Material(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_loadingOverlay!);
  }

  void _hideLoading() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items == null && widget.asyncItems == null) {
      throw "No items provided for context menu";
    }

    final content = widget.child;

    Widget wrappedChild = content;

    if (widget.onTapToo) {
      wrappedChild = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTapDown: _storePosition,
          onTap: () {
            print("tap");
            // same logic as GestureDetector onTap
            if (widget.onPressed != null) widget.onPressed!();
            if (_tapPosition != null) {
              _showContextMenu(context, _tapPosition!);
            }
          },
          child: content,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (s) {
        print("tap down");
        _storePosition(s);
      },
      // onTap: () {
      //   if (!widget.onTapToo) {
      //     if (widget.onPressed != null) widget.onPressed!();
      //     if (_tapPosition != null) {
      //       _showContextMenu(context, _tapPosition!);
      //     }
      //   }
      // },
      onSecondaryTapDown: (details) {
        print("secondary tap");
        _showContextMenu(context, details.globalPosition);
      },
      onLongPress: () {
        print("long press");
        _showContextMenu(context, _tapPosition ?? Offset.zero);
      },
      child: wrappedChild,
    );
  }
}
