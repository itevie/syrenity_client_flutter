import 'package:flutter/material.dart';

class ProminentBannerDetails {
  final Color color;
  final String text;
  final (String, Function(BuildContext)) button;

  const ProminentBannerDetails({
    required this.color,
    required this.text,
    required this.button,
  });
}

class ProminentBannerWidget extends StatelessWidget {
  final ProminentBannerDetails details;

  const ProminentBannerWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(details.color);

    final textColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: details.color,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                details.text,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          TextButton(
            onPressed: () => details.button.$2(context),
            style: TextButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(color: textColor, width: 1),
            ),
            child: Text(details.button.$1),
          ),
        ],
      ),
    );
  }
}
