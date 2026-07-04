import 'package:flutter/material.dart';
import '../../services/nutri_database.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final name = TextEditingController(text: 'Lucas');
  final age = TextEditingController(text: '33');
  final weight = TextEditingController(text: '83');
  final height = TextEditingController(text: '169');
  final wakeTime = TextEditingController(text: '07:00');
  final sleepTime = TextEditingController(text: '23:00');
  final mealsTimes = TextEditingController(text: '09h café, 11h almoço, 15h café da tarde, noite jantar');
  final trainingRoutine = TextEditingController(text: 'Academia segunda, terça e quinta. Esteira segunda, quarta e sexta.');
  final workRoutine = TextEditingController(text: 'Rotina normal do dia, alternando sentado e em pé.');
  final likes = TextEditingController(text: 'pão, ovos, arroz, frango, carne, batata doce, banana, iogurte, whey, hambúrguer, pizza');
  final drinks = TextEditingController(text: 'água, água com gás, café com leite, whey com leite');
  final dislikes = TextEditingController(text: 'peixe, salada, comida japonesa');
  final medicines = TextEditingController(text: 'creatina, whey, vitaminas/remédios conforme cadastrar');
  String sex = 'masculino';
  String goal = 'Emagrecer e ganhar massa';
  bool freeWeekendNight = true;
  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);
    try {
      await NutriDatabase().completeOnboarding(
        name: name.text,
        age: int.tryParse(age.text) ?? 33,
        sex: sex,
        weightKg: double.tryParse(weight.text.replaceAll(',', '.')) ?? 83,
        heightCm: double.tryParse(height.text.replaceAll(',', '.')) ?? 169,
        goal: goal,
        wakeTime: wakeTime.text,
        sleepTime: sleepTime.text,
        mealsTimes: mealsTimes.text,
        trainingRoutine: trainingRoutine.text,
        workRoutine: workRoutine.text,
        likes: likes.text,
        drinks: drinks.text,
        dislikes: dislikes.text,
        medicines: medicines.text,
        freeWeekendNight: freeWeekendNight,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget field(String label, TextEditingController controller, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines == 1 ? 1 : 5,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração inicial'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text('Vamos personalizar seu Nutri IA', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Essas informações serão usadas para calcular calorias, água, proteína e montar seu cardápio.'),
              const SizedBox(height: 22),
              field('Nome', name),
              Row(
                children: [
                  Expanded(child: field('Idade', age)),
                  const SizedBox(width: 12),
                  Expanded(child: field('Peso kg', weight)),
                  const SizedBox(width: 12),
                  Expanded(child: field('Altura cm', height)),
                ],
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: sex,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: const [
                  DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                ],
                onChanged: (value) => setState(() => sex = value ?? sex),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: goal,
                decoration: const InputDecoration(labelText: 'Objetivo'),
                items: const [
                  DropdownMenuItem(value: 'Emagrecer', child: Text('Emagrecer')),
                  DropdownMenuItem(value: 'Ganhar massa', child: Text('Ganhar massa')),
                  DropdownMenuItem(value: 'Emagrecer e ganhar massa', child: Text('Emagrecer e ganhar massa')),
                  DropdownMenuItem(value: 'Manter peso', child: Text('Manter peso')),
                ],
                onChanged: (value) => setState(() => goal = value ?? goal),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: field('Hora que acorda', wakeTime)),
                  const SizedBox(width: 12),
                  Expanded(child: field('Hora que dorme', sleepTime)),
                ],
              ),
              field('Horários das refeições', mealsTimes, lines: 2),
              field('Rotina de treino', trainingRoutine, lines: 2),
              field('Rotina de trabalho/dia', workRoutine, lines: 2),
              field('Comidas que gosta', likes, lines: 3),
              field('Bebidas que gosta', drinks, lines: 2),
              field('O que não gosta / evita', dislikes, lines: 2),
              field('Remédios, vitaminas e suplementos', medicines, lines: 2),
              SwitchListTile(
                value: freeWeekendNight,
                onChanged: (value) => setState(() => freeWeekendNight = value),
                title: const Text('Liberar besteira controlada sábado e domingo à noite'),
                subtitle: const Text('O cardápio deixa espaço para pizza, hambúrguer ou lanche sem perder o controle.'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: loading ? null : save,
                icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                label: const Text('Finalizar e entrar no app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
