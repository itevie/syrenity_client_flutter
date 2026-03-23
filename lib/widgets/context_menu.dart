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
  final List<ContextMenuItem> Function() items;
  final bool onTapToo;
  const ContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.onTapToo = false,
  });

  @override
  State<StatefulWidget> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  Offset? _tapPosition;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _showContextMenu(BuildContext context, Offset other) async {
    final position = _tapPosition ?? other;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: widget.items().map((x) => buildMenuItem(x)).toList(),
    );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _storePosition,
      onTap: () {
        if (widget.onTapToo) _showContextMenu(context, _tapPosition!);
      },
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      onSecondaryTap:
          () => _showContextMenu(context, _tapPosition!), // right click
      onLongPress: () => _showContextMenu(context, _tapPosition!), // mobile
      child: widget.child,
    );
  }
}
