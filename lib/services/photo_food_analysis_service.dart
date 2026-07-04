class PhotoFoodResult {
  final String title;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int confidence;

  const PhotoFoodResult({
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
  });

  PhotoFoodResult multiplied(double multiplier) {
    return PhotoFoodResult(
      title: title,
      description: description,
      calories: (calories * multiplier).round(),
      protein: (protein * multiplier).round(),
      carbs: (carbs * multiplier).round(),
      fat: (fat * multiplier).round(),
      confidence: confidence,
    );
  }
}

class PhotoFoodAnalysisService {
  static PhotoFoodResult analyze({
    required String fileName,
    required String hint,
  }) {
    final text = '$fileName $hint'.toLowerCase();

    if (text.contains('pizza')) {
      return const PhotoFoodResult(
        title: 'Pizza',
        description: 'Estimativa para 2 fatias médias de pizza.',
        calories: 620,
        protein: 24,
        carbs: 62,
        fat: 30,
        confidence: 86,
      );
    }

    if (text.contains('hamb') || text.contains('lanche')) {
      return const PhotoFoodResult(
        title: 'Hambúrguer/Lanche',
        description: 'Estimativa para um hambúrguer médio.',
        calories: 700,
        protein: 35,
        carbs: 48,
        fat: 38,
        confidence: 78,
      );
    }

    if (text.contains('arroz') && text.contains('frango')) {
      return const PhotoFoodResult(
        title: 'Arroz com frango',
        description: 'Estimativa para arroz, frango e acompanhamento simples.',
        calories: 520,
        protein: 42,
        carbs: 55,
        fat: 12,
        confidence: 82,
      );
    }

    if (text.contains('frango')) {
      return const PhotoFoodResult(
        title: 'Frango com acompanhamento',
        description: 'Estimativa para frango grelhado com algum acompanhamento.',
        calories: 430,
        protein: 40,
        carbs: 32,
        fat: 12,
        confidence: 76,
      );
    }

    if (text.contains('ovo') || text.contains('pao') || text.contains('pão')) {
      return const PhotoFoodResult(
        title: 'Pão com ovos',
        description: 'Estimativa para pão com ovos no café da manhã.',
        calories: 350,
        protein: 20,
        carbs: 34,
        fat: 14,
        confidence: 80,
      );
    }

    if (text.contains('whey')) {
      return const PhotoFoodResult(
        title: 'Whey',
        description: 'Estimativa para 1 dose de whey.',
        calories: 120,
        protein: 24,
        carbs: 4,
        fat: 2,
        confidence: 85,
      );
    }

    if (text.contains('banana')) {
      return const PhotoFoodResult(
        title: 'Banana',
        description: 'Estimativa para 1 banana média.',
        calories: 90,
        protein: 1,
        carbs: 23,
        fat: 0,
        confidence: 85,
      );
    }

    if (text.contains('cafe') || text.contains('café')) {
      return const PhotoFoodResult(
        title: 'Café com leite',
        description: 'Estimativa para 1 copo/xícara de café com leite.',
        calories: 90,
        protein: 5,
        carbs: 10,
        fat: 3,
        confidence: 70,
      );
    }

    return const PhotoFoodResult(
      title: 'Refeição estimada',
      description: 'Estimativa genérica. Para melhorar, escreva uma dica: arroz com frango, pizza, lanche, ovos, etc.',
      calories: 400,
      protein: 20,
      carbs: 45,
      fat: 15,
      confidence: 55,
    );
  }
}
