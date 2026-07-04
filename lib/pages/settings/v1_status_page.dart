import 'package:flutter/material.dart';
import '../../services/v1_completion_service.dart';

class V1StatusPage extends StatelessWidget {
  const V1StatusPage({super.key});

  Color colorFor(int percent) {
    if (percent >= 90) return const Color(0xFF22C55E);
    if (percent >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final overall = V1CompletionService.overall();

    return Scaffold(
      appBar: AppBar(title: const Text('Status da versão 1.0')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorFor(overall),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progresso geral v1.0', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text('$overall%', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Meta: deixar uso diário 100% antes de IA real com Blaze.', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final item in V1CompletionService.items)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.module, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Text('${item.percent}%', style: TextStyle(fontWeight: FontWeight.bold, color: colorFor(item.percent))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: item.percent / 100, minHeight: 10, borderRadius: BorderRadius.circular(20)),
                  const SizedBox(height: 8),
                  Text(item.nextStep, style: TextStyle(color: Colors.white.withOpacity(.72))),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
