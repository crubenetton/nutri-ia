import 'package:flutter/material.dart';
import '../../core/constants/app_info.dart';
import '../about/about_page.dart';
import '../ai_photo/ai_photo_page.dart';
import '../coach/coach_page.dart';
import '../exercises/exercises_page.dart';
import '../food/food_page.dart';
import '../medicines/medicines_page.dart';
import '../plan/weekly_plan_page.dart';
import '../profile/profile_page.dart';
import '../progress/body_progress_page.dart';
import '../reports/reports_page.dart';
import '../settings/settings_page.dart';
import '../settings/v1_status_page.dart';
import 'home_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    HomePage(),
    WeeklyPlanPage(),
    FoodPage(),
    CoachPage(),
    ReportsPage(),
    ProfilePage(),
  ];

  void go(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text(
                  AppInfo.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Desenvolvido por ${AppInfo.developer}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Foto IA'),
                subtitle: const Text('Fluxo de análise de comida'),
                onTap: () => go(context, const AIPhotoPage()),
              ),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Exercícios'),
                onTap: () => go(context, const ExercisesPage()),
              ),
              ListTile(
                leading: const Icon(Icons.medication),
                title: const Text('Remédios e vitaminas'),
                onTap: () => go(context, const MedicinesPage()),
              ),
              ListTile(
                leading: const Icon(Icons.monitor_weight),
                title: const Text('Evolução corporal'),
                onTap: () => go(context, const BodyProgressPage()),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.rocket_launch),
                title: const Text('Status v1.0'),
                subtitle: const Text('Progresso dos módulos'),
                onTap: () => go(context, const V1StatusPage()),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configurações'),
                onTap: () => go(context, const SettingsPage()),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre'),
                onTap: () => go(context, const AboutPage()),
              ),
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Powered by ${AppInfo.developer}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Plano'),
          NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Comida'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'Coach'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Relatórios'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
