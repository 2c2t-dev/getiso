import 'package:flutter/material.dart';
import 'screens/iso_home_page.dart';

void main() {
  runApp(const GetIsoApp());
}

class DebugBadge extends StatelessWidget {
  const DebugBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // Affiche uniquement en mode debug
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    if (!inDebug) return const SizedBox.shrink();
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F).withAlpha((0.85 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).round()),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'DEBUG',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
            decoration: TextDecoration.none, // enlève tout soulignement
          ),
        ),
      ),
    );
  }
}

class GetIsoApp extends StatelessWidget {
  const GetIsoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2C2T-ISO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Stack(children: const [IsoHomePage(), DebugBadge()]),
    );
  }
}
