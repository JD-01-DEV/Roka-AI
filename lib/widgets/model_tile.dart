import 'package:flutter/material.dart';
import 'package:localgpt/main.dart';
import 'package:localgpt/themes/app_themes.dart';

class ModelTile extends StatelessWidget {
  final String name;
  final String size;
  final String parameters;
  final bool isLoaded;
  final VoidCallback onLoadUnlaod;
  final VoidCallback onSettings;
  final VoidCallback onDelete;

  const ModelTile({
    required this.name,
    required this.size,
    required this.parameters,
    required this.isLoaded,
    required this.onLoadUnlaod,
    required this.onSettings,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDarkMode ? AppThemes.secondaryDark : AppThemes.secondaryLight,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.memory,
              color: isDarkMode ? AppThemes.accentDark : AppThemes.accentLight,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isDarkMode
                          ? AppThemes.primaryTextDark
                          : AppThemes.primaryTextLight,
                    ),
                  ),
                  Text(
                    "Size: $size • Params: $parameters",
                    style: TextStyle(
                      color: isDarkMode
                          ? AppThemes.secondaryTextDark
                          : AppThemes.secondaryTextLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onLoadUnlaod,
              icon: Icon(
                isLoaded ? Icons.stop_circle_outlined : Icons.play_arrow,
                color: isLoaded ? Colors.redAccent : Colors.greenAccent,
              ),
            ),

            IconButton(
              onPressed: onSettings,
              icon: Icon(
                Icons.tune,
                color: isDarkMode
                    ? AppThemes.primaryTextDark
                    : AppThemes.primaryTextLight,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete,
                color: isDarkMode
                    ? AppThemes.primaryTextDark
                    : AppThemes.primaryTextLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
