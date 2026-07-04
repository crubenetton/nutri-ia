class FoodItemEstimate {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const FoodItemEstimate({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class FoodAIResult {
  final String title;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String explanation;
  final List<FoodItemEstimate> items;

  const FoodAIResult({
    required this.title,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.explanation,
    required this.items,
  });
}

class FoodData {
  final String name;
  final List<String> keys;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const FoodData({
    required this.name,
    required this.keys,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class FoodAIEstimator {
  static const foods = <FoodData>[
    FoodData(name: 'ovo', keys: ['ovo', 'ovos'], calories: 78, protein: 6, carbs: 1, fat: 5),
    FoodData(name: 'pão francês', keys: ['pão', 'pao', 'pães', 'paes', 'pão francês', 'pao frances'], calories: 140, protein: 5, carbs: 28, fat: 1),
    FoodData(name: 'manteiga', keys: ['manteiga'], calories: 75, protein: 0, carbs: 0, fat: 8),
    FoodData(name: 'requeijão', keys: ['requeijão', 'requeijao'], calories: 80, protein: 3, carbs: 2, fat: 7),
    FoodData(name: 'queijo', keys: ['queijo', 'mussarela', 'muçarela'], calories: 90, protein: 6, carbs: 1, fat: 7),
    FoodData(name: 'café com leite', keys: ['café com leite', 'cafe com leite'], calories: 90, protein: 5, carbs: 10, fat: 3),
    FoodData(name: 'café', keys: ['café', 'cafe'], calories: 10, protein: 0, carbs: 1, fat: 0),
    FoodData(name: 'leite', keys: ['leite'], calories: 120, protein: 6, carbs: 12, fat: 6),
    FoodData(name: 'whey', keys: ['whey', 'whey protein'], calories: 120, protein: 24, carbs: 4, fat: 2),
    FoodData(name: 'banana', keys: ['banana', 'bananas'], calories: 90, protein: 1, carbs: 23, fat: 0),
    FoodData(name: 'iogurte', keys: ['iogurte'], calories: 120, protein: 8, carbs: 14, fat: 3),
    FoodData(name: 'arroz', keys: ['arroz'], calories: 220, protein: 4, carbs: 45, fat: 1),
    FoodData(name: 'feijão', keys: ['feijão', 'feijao'], calories: 120, protein: 7, carbs: 20, fat: 1),
    FoodData(name: 'frango', keys: ['frango', 'peito de frango'], calories: 250, protein: 38, carbs: 0, fat: 8),
    FoodData(name: 'carne', keys: ['carne', 'bife'], calories: 300, protein: 32, carbs: 0, fat: 18),
    FoodData(name: 'batata doce', keys: ['batata doce'], calories: 160, protein: 3, carbs: 37, fat: 0),
    FoodData(name: 'macarrão', keys: ['macarrão', 'macarrao'], calories: 300, protein: 10, carbs: 60, fat: 2),
    FoodData(name: 'hambúrguer', keys: ['hambúrguer', 'hamburguer', 'lanche', 'x salada', 'x-salada'], calories: 700, protein: 35, carbs: 48, fat: 38),
    FoodData(name: 'pizza', keys: ['pizza', 'fatia de pizza', 'pedaço de pizza', 'pedaco de pizza'], calories: 310, protein: 12, carbs: 31, fat: 15),
    FoodData(name: 'batata frita', keys: ['batata frita', 'fritas'], calories: 380, protein: 5, carbs: 48, fat: 19),
    FoodData(name: 'linguiça', keys: ['linguiça', 'linguica'], calories: 250, protein: 14, carbs: 2, fat: 21),
    FoodData(name: 'chocolate', keys: ['chocolate'], calories: 250, protein: 3, carbs: 30, fat: 14),
    FoodData(name: 'sorvete', keys: ['sorvete'], calories: 220, protein: 4, carbs: 32, fat: 8),
    FoodData(name: 'açaí', keys: ['açaí', 'acai'], calories: 400, protein: 6, carbs: 70, fat: 10),
    FoodData(name: 'pastel', keys: ['pastel'], calories: 420, protein: 12, carbs: 38, fat: 24),
    FoodData(name: 'coxinha', keys: ['coxinha'], calories: 320, protein: 11, carbs: 32, fat: 17),
    FoodData(name: 'pão de queijo', keys: ['pão de queijo', 'pao de queijo'], calories: 180, protein: 5, carbs: 20, fat: 9),
    FoodData(name: 'suco de laranja', keys: ['suco de laranja'], calories: 110, protein: 1, carbs: 26, fat: 0),
    FoodData(name: 'refrigerante', keys: ['refrigerante', 'coca', 'coca-cola', 'guaraná', 'guarana'], calories: 140, protein: 0, carbs: 35, fat: 0),
    FoodData(name: 'cerveja', keys: ['cerveja'], calories: 150, protein: 1, carbs: 13, fat: 0),
  ];

  static FoodAIResult estimate(String input) {
    final text = input.toLowerCase();

    final items = <FoodItemEstimate>[];
    final used = <String>{};

    for (final food in foods) {
      final matchedKey = food.keys.where((key) => text.contains(key)).toList();
      if (matchedKey.isEmpty) continue;

      if (food.name == 'café' && (text.contains('café com leite') || text.contains('cafe com leite'))) {
        continue;
      }

      if (food.name == 'leite' && (text.contains('café com leite') || text.contains('cafe com leite'))) {
        continue;
      }

      if (used.contains(food.name)) continue;
      used.add(food.name);

      final qty = _quantityForFood(text, food);
      items.add(FoodItemEstimate(
        name: qty > 1 ? '$qty ${food.name}' : food.name,
        calories: food.calories * qty,
        protein: food.protein * qty,
        carbs: food.carbs * qty,
        fat: food.fat * qty,
      ));
    }

    if (items.isEmpty) {
      items.add(const FoodItemEstimate(
        name: 'estimativa genérica',
        calories: 300,
        protein: 10,
        carbs: 35,
        fat: 10,
      ));
    }

    final calories = items.fold<int>(0, (sum, item) => sum + item.calories);
    final protein = items.fold<int>(0, (sum, item) => sum + item.protein);
    final carbs = items.fold<int>(0, (sum, item) => sum + item.carbs);
    final fat = items.fold<int>(0, (sum, item) => sum + item.fat);
    final title = items.map((e) => e.name).join(', ');

    return FoodAIResult(
      title: title,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      explanation: 'Estimativa local com banco de alimentos ampliado. Ajuste a quantidade antes de salvar para ficar mais próximo da realidade.',
      items: items,
    );
  }

  static int _quantityForFood(String text, FoodData food) {
    for (final key in food.keys) {
      final patterns = [
        RegExp('(\\d+)\\s+' + RegExp.escape(key)),
        RegExp('(\\d+)\\s+unidades?\\s+de\\s+' + RegExp.escape(key)),
        RegExp('(\\d+)\\s+fatias?\\s+de\\s+' + RegExp.escape(key)),
        RegExp('(\\d+)\\s+pedaços?\\s+de\\s+' + RegExp.escape(key)),
        RegExp('(\\d+)\\s+pedacos?\\s+de\\s+' + RegExp.escape(key)),
      ];

      for (final regex in patterns) {
        final match = regex.firstMatch(text);
        if (match != null) {
          return int.tryParse(match.group(1) ?? '') ?? 1;
        }
      }
    }

    if (food.name == 'pizza') {
      final q = _quantityBeforeWords(text, ['fatia', 'fatias', 'pedaço', 'pedaços', 'pedaco', 'pedacos']);
      if (q > 0) return q;
      return 2;
    }

    if (food.name == 'ovo') {
      final q = _quantityBeforeWords(text, ['ovo', 'ovos']);
      if (q > 0) return q;
    }

    if (food.name == 'banana') {
      final q = _quantityBeforeWords(text, ['banana', 'bananas']);
      if (q > 0) return q;
    }

    return 1;
  }

  static int _quantityBeforeWords(String text, List<String> words) {
    for (final word in words) {
      final regex = RegExp('(\\d+)\\s+' + RegExp.escape(word));
      final match = regex.firstMatch(text);
      if (match != null) return int.tryParse(match.group(1) ?? '') ?? 1;
    }
    return 0;
  }
}
