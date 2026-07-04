import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_database.dart';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  final name = TextEditingController();
  final dose = TextEditingController();
  final time = TextEditingController();
  bool loading = false;

  Future<void> saveMedicine() async {
    setState(() => loading = true);
    try {
      await NutriDatabase().addMedicine(
        name: name.text.trim().isEmpty ? 'Medicamento/Vitamina' : name.text,
        dose: dose.text.trim().isEmpty ? 'Dose não informada' : dose.text,
        time: time.text.trim().isEmpty ? 'Horário não informado' : time.text,
      );

      name.clear();
      dose.clear();
      time.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remédio/Vitamina salvo.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> markTaken(String id) async {
    await NutriDatabase().markMedicineTaken(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marcado como tomado hoje.')));
  }

  Future<void> deleteMedicine(String id) async {
    await NutriDatabase().deleteMedicine(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remédio/Vitamina apagado.')));
  }

  String takenText(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp) return 'Ainda não marcado como tomado.';
    final date = timestamp.toDate();
    return 'Última confirmação: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget quick(String title, String doseText, String timeText) {
    return ActionChip(
      label: Text(title),
      onPressed: () async {
        await NutriDatabase().addMedicine(name: title, dose: doseText, time: timeText);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remédios e vitaminas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Controle diário', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Cadastre remédios, vitaminas e suplementos para acompanhar no app.', style: TextStyle(color: Colors.white.withOpacity(.75))),
          const SizedBox(height: 16),

          const Text('Atalhos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              quick('Creatina', '3g a 5g', 'Todos os dias'),
              quick('Whey', '1 dose', 'Quando precisar bater proteína'),
              quick('Vitamina D', 'Conforme prescrição', 'Horário fixo'),
              quick('Levetiracetam', 'Conforme prescrição médica', 'Horário fixo'),
            ],
          ),

          const SizedBox(height: 22),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 12),
          TextField(controller: dose, decoration: const InputDecoration(labelText: 'Dose / quantidade')),
          const SizedBox(height: 12),
          TextField(controller: time, decoration: const InputDecoration(labelText: 'Horário')),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : saveMedicine,
            icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add),
            label: const Text('Salvar'),
          ),

          const SizedBox(height: 24),
          const Text('Lista cadastrada', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: NutriDatabase().medicinesStream(),
            builder: (context, snapshot) {
              final items = snapshot.data?.docs ?? [];

              if (items.isEmpty) {
                return const Card(child: ListTile(title: Text('Nenhum remédio/vitamina cadastrado.')));
              }

              return Column(
                children: [
                  for (final item in items)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.medication),
                        title: Text((item.data()['name'] ?? 'Medicamento').toString()),
                        subtitle: Text('${item.data()['dose'] ?? ''} • ${item.data()['time'] ?? ''}\n${takenText(item.data()['lastTakenAt'])}'),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline),
                              onPressed: () => markTaken(item.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => deleteMedicine(item.id),
                            ),
                          ],
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
