import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/auth_gate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07111F), Color(0xFF0F766E), Color(0xFF16A34A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 96, color: Colors.white),
            SizedBox(height: 22),
            Text('Nutri IA', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white)),
            SizedBox(height: 8),
            Text('Seu Coach Inteligente de Saúde', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white70)),
            SizedBox(height: 34),
            Text('Powered by', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 4),
            Text('Cru Benetton®', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
            SizedBox(height: 36),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
