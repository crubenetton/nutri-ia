import 'package:flutter/material.dart';
import '../../core/constants/app_info.dart';
import '../../services/auth_service.dart';
import '../../services/nutri_database.dart';
import 'v1_status_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> resetWater(BuildContext context) async {
    await NutriDatabase().resetWaterToday();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Água de hoje zerada.')),
    );
  }

  Future<void> logout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Icon(Icons.health_and_safety, size: 72, color: Color(0xFF22C55E)),
          const SizedBox(height: 12),
          const Text(AppInfo.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text(AppInfo.slogan, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          sectionTitle('Uso diário'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.water_drop),
                  title: const Text('Zerar água de hoje'),
                  subtitle: const Text('Use quando começar um novo dia.'),
                  trailing: const Icon(Icons.restart_alt),
                  onTap: () => resetWater(context),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.tips_and_updates),
                  title: Text('Dica'),
                  subtitle: Text('Registre comida, água, exercício e peso todos os dias para o Coach ficar melhor.'),
                ),
              ],
            ),
          ),
          sectionTitle('Versão 1.0'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.rocket_launch),
              title: const Text('Ver progresso da v1.0'),
              subtitle: const Text('Acompanhe o que já está pronto e o que falta.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const V1StatusPage())),
            ),
          ),
          sectionTitle('Próximas funções'),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('IA por foto'),
                  subtitle: Text('Reconhecer comida por imagem em versão futura.'),
                ),
                ListTile(
                  leading: Icon(Icons.notifications_active),
                  title: Text('Notificações inteligentes'),
                  subtitle: Text('Água, remédios, proteína, treino e peso.'),
                ),
                ListTile(
                  leading: Icon(Icons.insert_chart),
                  title: Text('Gráficos premium'),
                  subtitle: Text('Peso, calorias, proteína, água e evolução semanal.'),
                ),
              ],
            ),
          ),
          sectionTitle('Conta'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair da conta'),
              subtitle: const Text('Voltar para a tela de login.'),
              onTap: () => logout(context),
            ),
          ),
          sectionTitle('Sobre'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: const [
                  Text('Desenvolvido por', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text(AppInfo.developer, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text('Versão ${AppInfo.version}'),
                  SizedBox(height: 4),
                  Text(AppInfo.copyright, style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
