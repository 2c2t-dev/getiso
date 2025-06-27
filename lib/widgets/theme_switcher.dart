import 'package:flutter/material.dart';

class ThemeSwitcher extends StatelessWidget {
  final bool isDark;
  final VoidCallback toggleTheme;
  const ThemeSwitcher({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: toggleTheme,
        backgroundColor: isDark ? Colors.deepPurple : Colors.white,
        tooltip: isDark ? 'Mode clair' : 'Mode sombre',
        elevation: 4,
        child: Icon(
          isDark ? Icons.nightlight_round : Icons.wb_sunny,
          color: isDark ? Colors.white : Colors.deepPurple,
          size: 28,
        ),
      ),
    );
  }
}
