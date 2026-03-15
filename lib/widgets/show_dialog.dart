import 'package:flutter/material.dart';

void showSyDialog(BuildContext context, Widget widget) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget,
        ),
  );
}
