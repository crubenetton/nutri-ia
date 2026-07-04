import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_database.dart';

class BodyProgressPage extends StatefulWidget {
  const BodyProgressPage({super.key});

  @override
  State<BodyProgressPage> createState() => _BodyProgressPageState();
}

class _BodyProgressPageState extends State<BodyProgressPage> {
  final weight = TextEditingController();
  final waist = TextEditingController();
  final notes = TextEditingController();
  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);
    try {
      await NutriDatabase().addBodyProgress(
        weightKg: double.tryParse(weight.text.replaceAll(',', '.')) ?? 0,
        waistCm: double.tryParse(waist.text.replaceAll(',', '.')) ?? 0,
        notes: notes.text,
      );

      weight.clear();
      waist.clear();
      notes.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evolução salva.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteProgress(String id) async {
    await NutriDatabase().deleteBodyProgress(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro apagado.')));
  }

  String dateText(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp) return 'Data não informada';
    final date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolução corporal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Peso e medidas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Registre peso e cintura para comparar sua evolução.', style: TextStyle(color: Colors.white.withOpacity(.75))),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: TextField(controller: weight, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso kg'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: waist, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cintura cm'))),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: notes, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Observações')),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : save,
            icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
            label: const Text('Salvar evolução'),
          ),

          const SizedBox(height: 24),
          const Text('Histórico', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: NutriDatabase().bodyProgressStream(),
            builder: (context, snapshot) {
              final items = snapshot.data?.docs ?? [];
              if (items.isEmpty) {
                return const Card(child: ListTile(title: Text('Nenhum registro de evolução ainda.')));
              }

              final newest = items.first.data();
              final oldest = items.last.data();
              final newestWeight = ((newest['weightKg'] ?? 0) as num).toDouble();
              final oldestWeight = ((oldest['weightKg'] ?? newestWeight) as num).toDouble();
              final diff = newestWeight - oldestWeight;

              return Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.trending_down),
                      title: Text(diff < 0 ? 'Você perdeu ${diff.abs().toStringAsFixed(1)} kg' : 'Variação de ${diff.toStringAsFixed(1)} kg'),
                      subtitle: const Text('Comparando primeiro e último registro.'),
                    ),
                  ),
                  for (final item in items)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.monitor_weight),
                        title: Text('${item.data()['weightKg'] ?? 0} kg • cintura ${item.data()['waistCm'] ?? 0} cm'),
                        subtitle: Text('${dateText(item.data()['createdAt'])}\n${item.data()['notes'] ?? ''}'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => deleteProgress(item.id),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
