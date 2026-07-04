import 'package:flutter/material.dart';
import '../../widgets/action_tile.dart';
import '../../widgets/metric_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutri IA'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Bom dia, Lucas 👋', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Seu assistente inteligente de saúde, alimentação e rotina.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(.70), fontSize: 15)),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF0F766E)])),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meta de hoje', style: TextStyle(fontSize: 16, color: Colors.white70)),
                SizedBox(height: 8),
                Text('1.250 / 2.200 kcal', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
                SizedBox(height: 10),
                LinearProgressIndicator(value: .56, minHeight: 10, borderRadius: BorderRadius.all(Radius.circular(99)), backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(children: [Expanded(child: MetricCard(icon: Icons.local_fire_department, title: 'Gasto', value: '640', unit: 'kcal')), SizedBox(width: 12), Expanded(child: MetricCard(icon: Icons.water_drop, title: 'Água', value: '1,8', unit: 'L'))]),
          const SizedBox(height: 12),
          const Row(children: [Expanded(child: MetricCard(icon: Icons.fitness_center, title: 'Proteína', value: '92', unit: 'g')), SizedBox(width: 12), Expanded(child: MetricCard(icon: Icons.monitor_weight, title: 'Peso', value: '83', unit: 'kg'))]),
          const SizedBox(height: 22),
          const Text('Ações rápidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ActionTile(icon: Icons.add_circle_outline, title: 'Adicionar refeição', subtitle: 'Registrar comida, bebida ou suplemento', onTap: () {}),
          ActionTile(icon: Icons.camera_alt_outlined, title: 'Analisar foto com IA', subtitle: 'Comida, bebida ou remédio por imagem', onTap: () {}),
          ActionTile(icon: Icons.medication_outlined, title: 'Registrar medicamento', subtitle: 'Horário, dose e lembrete', onTap: () {}),
          ActionTile(icon: Icons.bar_chart_outlined, title: 'Relatório de ontem no WhatsApp', subtitle: 'Todo dia às 7h enviar resumo automático', onTap: () {}),
        ],
      ),
    );
  }
}
