import 'package:flutter/material.dart';
import 'package:roka_ai/main.dart';
import 'package:roka_ai/themes/app_themes.dart';

class SettingOptionTile extends StatefulWidget {
  final Widget title;
  final Widget? subTitle;
  final Widget? leading;
  final Widget? trailing;
  final double? overrideBorderRadius;
  final double? overridePaddingV;
  final double? overridePaddingH;

  const SettingOptionTile({
    required this.title,
    this.subTitle,
    this.leading,
    this.trailing,
    this.overrideBorderRadius,
    this.overridePaddingV,
    this.overridePaddingH,
    super.key,
  });

  @override
  SettingOptionTileState createState() => SettingOptionTileState();
}

class SettingOptionTileState extends State<SettingOptionTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(
        vertical: widget.overridePaddingV ?? 10,
        horizontal: widget.overridePaddingH ?? 0,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemes.secondaryDark : AppThemes.secondaryLight,
        borderRadius: BorderRadius.all(
          Radius.circular(widget.overrideBorderRadius ?? 30),
        ),
      ),
      child: ListTile(
        title: widget.title,
        subtitle: widget.subTitle,
        leading: widget.leading,
        trailing: widget.trailing,
      ),
    );
  }
}
