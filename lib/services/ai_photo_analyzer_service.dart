class PhotoAnalysisResult {
  final String title;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int confidence;

  const PhotoAnalysisResult({
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
  });
}

class AIPhotoAnalyzerService {
  static PhotoAnalysisResult simulateFoodPhoto(String description) {
    final text = description.toLowerCase();

    if (text.contains('pizza')) {
      return const PhotoAnalysisResult(
        title: 'Pizza detectada',
        description: 'Estimativa para 2 fatias médias de pizza.',
        calories: 620,
        protein: 24,
        carbs: 62,
        fat: 30,
        confidence: 86,
      );
    }

    if (text.contains('arroz') && text.contains('frango')) {
      return const PhotoAnalysisResult(
        title: 'Arroz com frango',
        description: 'Estimativa para prato com arroz e frango grelhado.',
        calories: 520,
        protein: 42,
        carbs: 55,
        fat: 12,
        confidence: 82,
      );
    }

    if (text.contains('ovo') || text.contains('pão') || text.contains('pao')) {
      return const PhotoAnalysisResult(
        title: 'Café com pão e ovos',
        description: 'Estimativa para pão com ovos no café da manhã.',
        calories: 350,
        protein: 20,
        carbs: 34,
        fat: 14,
        confidence: 80,
      );
    }

    if (text.contains('hamb')) {
      return const PhotoAnalysisResult(
        title: 'Hambúrguer',
        description: 'Estimativa para hambúrguer artesanal médio.',
        calories: 700,
        protein: 35,
        carbs: 48,
        fat: 38,
        confidence: 78,
      );
    }

    return const PhotoAnalysisResult(
      title: 'Refeição estimada',
      description: 'Estimativa genérica até ativarmos a IA de imagem real.',
      calories: 400,
      protein: 20,
      carbs: 45,
      fat: 15,
      confidence: 60,
    );
  }
}
