import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_database.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final manual = TextEditingController();
  bool loading = false;

  Future<void> add(BuildContext context, int ml) async {
    await NutriDatabase().addWater(ml);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+${ml}ml de água registrado.')));
  }

  Future<void> remove(BuildContext context, int ml) async {
    await NutriDatabase().removeWater(ml);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('-${ml}ml removido.')));
  }

  Future<void> addManual(BuildContext context) async {
    final ml = int.tryParse(manual.text.trim()) ?? 0;
    if (ml <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite uma quantidade válida em ml.')));
      return;
    }
    await add(context, ml);
    manual.clear();
  }

  Future<void> removeManual(BuildContext context) async {
    final ml = int.tryParse(manual.text.trim()) ?? 0;
    if (ml <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite uma quantidade válida em ml.')));
      return;
    }
    await remove(context, ml);
    manual.clear();
  }

  Future<void> setManual(BuildContext context) async {
    final ml = int.tryParse(manual.text.trim()) ?? -1;
    if (ml < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite uma quantidade válida em ml.')));
      return;
    }
    await NutriDatabase().setWaterToday(ml);
    manual.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Água ajustada para ${ml}ml.')));
  }

  Future<void> reset(BuildContext context) async {
    await NutriDatabase().resetWaterToday();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Água de hoje zerada.')));
  }

  String coachMessage(double consumed, double goal) {
    final missing = goal - consumed;
    if (missing <= 0) return 'Meta de água batida hoje. Excelente!';
    if (missing <= 0.5) return 'Você está muito perto da meta.';
    if (missing <= 1.2) return 'Ainda falta um pouco de água. Beba aos poucos.';
    return 'A hidratação está atrasada. Comece com 500ml agora.';
  }

  Widget quickButton(BuildContext context, int ml) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(onPressed: () => add(context, ml), child: Text('+${ml}ml')),
        const SizedBox(width: 6),
        OutlinedButton(onPressed: () => remove(context, ml), child: Text('-${ml}ml')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: NutriDatabase().userStream(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final waterMl = ((data['waterMlToday'] ?? 0) as num).toInt();
        final goalLiters = ((data['waterGoalLiters'] ?? 2.9) as num).toDouble();
        final goalMl = (goalLiters * 1000).round();
        final consumedLiters = waterMl / 1000;
        final progress = goalMl <= 0 ? 0.0 : waterMl / goalMl;
        final missingMl = (goalMl - waterMl).clamp(0, 99999);

        return Scaffold(
          appBar: AppBar(title: const Text('Água Inteligente')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Hidratação de hoje', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Adicione, remova ou ajuste manualmente.', style: TextStyle(color: Colors.white.withOpacity(.72))),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Água consumida', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${consumedLiters.toStringAsFixed(1)} L',
                        style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Meta: ${goalLiters.toStringAsFixed(1)} L • faltam ${missingMl}ml',
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 14,
                      borderRadius: BorderRadius.circular(100),
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('Adicionar ou remover rápido', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  quickButton(context, 250),
                  quickButton(context, 500),
                  quickButton(context, 750),
                  quickButton(context, 1000),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Quantidade manual', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              TextField(
                controller: manual,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade em ml', hintText: 'Ex: 350'),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(onPressed: () => addManual(context), icon: const Icon(Icons.add), label: const Text('Adicionar manual')),
                  OutlinedButton.icon(onPressed: () => removeManual(context), icon: const Icon(Icons.remove), label: const Text('Remover manual')),
                  OutlinedButton.icon(onPressed: () => setManual(context), icon: const Icon(Icons.edit), label: const Text('Definir total do dia')),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('🤖 Coach da hidratação', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(coachMessage(consumedLiters, goalLiters)),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('Zerar água de hoje'),
                  subtitle: const Text('Use quando começar um novo dia ou registrar muito errado.'),
                  onTap: () => reset(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
