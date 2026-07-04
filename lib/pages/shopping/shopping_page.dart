import 'package:flutter/material.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ['Ovos', 'Frango', 'Arroz', 'Batata doce', 'Banana', 'Café', 'Leite', 'Iogurte', 'Whey', 'Creatina'];

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de compras')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Comprar esta semana', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          for (final item in items)
            CheckboxListTile(value: false, onChanged: (_) {}, title: Text(item)),
        ],
      ),
    );
  }
}
