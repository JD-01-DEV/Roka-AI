import 'package:flutter/material.dart';
import 'package:roka_ai/main.dart';

class IconBtn extends StatelessWidget {
  Icon icon;
  void Function()? onPressed;
  Color darkThemeColor;
  Color lightThemeColor;
  BorderRadius borderRadius;
  EdgeInsetsGeometry? padding;
  EdgeInsetsGeometry? margin;

  IconBtn({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.darkThemeColor,
    required this.lightThemeColor,
    required this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? darkThemeColor : lightThemeColor,
        borderRadius: borderRadius,
      ),
      padding: padding,
      margin: margin,

      child: IconButton(onPressed: onPressed, icon: icon),
    );
  }
}
