import 'package:flutter/material.dart';

class PremiumProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final IconData icon;

  const PremiumProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: const Color(0xFF22C55E)),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: safeProgress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(100),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.68))),
          ],
        ),
      ),
    );
  }
}
