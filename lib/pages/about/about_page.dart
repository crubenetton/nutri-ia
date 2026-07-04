import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Icon(Icons.health_and_safety, size: 78, color: Color(0xFF22C55E)),
          const SizedBox(height: 16),
          const Text('Nutri IA', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'Assistente inteligente de alimentação, água, exercícios, remédios e evolução corporal.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(.75)),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Text('Desenvolvido por', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text('Cru Benetton®', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                  SizedBox(height: 12),
                  Text('Versão 1.0.0'),
                  SizedBox(height: 4),
                  Text('© 2026 Todos os direitos reservados.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
