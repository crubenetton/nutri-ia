import 'nutri_brain_service.dart';

class NutriAIAnswer {
  final String title;
  final String message;
  final int? estimatedCalories;
  final int? estimatedProtein;
  final bool canRegisterMeal;

  const NutriAIAnswer({
    required this.title,
    required this.message,
    this.estimatedCalories,
    this.estimatedProtein,
    this.canRegisterMeal = false,
  });
}

class NutriAIContext {
  final String name;
  final String goal;
  final String likes;
  final String dislikes;
  final String drinks;
  final String trainingRoutine;
  final NutriDaySummary day;

  const NutriAIContext({
    required this.name,
    required this.goal,
    required this.likes,
    required this.dislikes,
    required this.drinks,
    required this.trainingRoutine,
    required this.day,
  });
}

class NutriAIService {
  static NutriAIAnswer ask({
    required String question,
    required NutriAIContext context,
  }) {
    final q = question.toLowerCase().trim();

    if (q.isEmpty) {
      return const NutriAIAnswer(
        title: 'Pergunta vazia',
        message: 'Digite o que você comeu, quer comer ou quer saber.',
      );
    }

    if (_isFoodLog(q)) {
      return _estimateFood(question, context);
    }

    if (q.contains('pizza')) {
      return NutriAIAnswer(
        title: 'Pizza hoje',
        message: context.day.pizzaAdvice(),
      );
    }

    if (q.contains('hamburg') || q.contains('lanche')) {
      final ok = context.day.availableCalories >= 650;
      return NutriAIAnswer(
        title: 'Hambúrguer',
        message: ok
            ? 'Pode encaixar um hambúrguer hoje. Como ainda restam ${context.day.availableCalories} kcal, tente evitar batata frita grande e refrigerante.'
            : 'Hoje está apertado para hambúrguer. Se quiser muito, escolha um menor e tente compensar com proteína e água.',
      );
    }

    if (q.contains('jantar') || q.contains('noite')) {
      return NutriAIAnswer(
        title: 'Sugestão para noite',
        message: context.day.dinnerSuggestion(),
      );
    }

    if (q.contains('água') || q.contains('agua') || q.contains('beber')) {
      return NutriAIAnswer(
        title: 'Água',
        message: 'Hoje faltam ${context.day.waterMissing.toStringAsFixed(1)} L de água. Beba aos poucos. Uma boa estratégia é beber um copo agora e outro antes da próxima refeição.',
      );
    }

    if (q.contains('proteína') || q.contains('proteina')) {
      return NutriAIAnswer(
        title: 'Proteína',
        message: 'Faltam ${context.day.proteinMissing} g de proteína. Para você, boas opções são: ovos, frango, whey, iogurte ou carne. Seus favoritos cadastrados são: ${context.likes}.',
      );
    }

    if (q.contains('doce') || q.contains('chocolate') || q.contains('sorvete')) {
      final ok = context.day.availableCalories >= 300;
      return NutriAIAnswer(
        title: 'Vontade de doce',
        message: ok
            ? 'Pode encaixar um doce pequeno. Você ainda tem ${context.day.availableCalories} kcal livres. Uma opção melhor seria iogurte com whey ou banana com canela.'
            : 'Hoje está apertado para doce. Se a vontade estiver forte, prefira uma porção pequena ou uma opção com proteína.',
      );
    }

    if (q.contains('cardápio') || q.contains('cardapio') || q.contains('semana')) {
      return NutriAIAnswer(
        title: 'Cardápio inteligente',
        message: 'Com base no seu objetivo (${context.goal}) e nos alimentos que você gosta (${context.likes}), o ideal é manter café com proteína, almoço com arroz e frango/carne, lanche com whey ou iogurte e jantar leve. No sábado e domingo à noite, podemos deixar uma refeição livre controlada.',
      );
    }

    return NutriAIAnswer(
      title: 'Coach IA',
      message: '${context.day.coachMessage} ${context.day.dinnerSuggestion()}',
    );
  }

  static bool _isFoodLog(String q) {
    final words = ['comi', 'tomei', 'bebi', 'almocei', 'jantei', 'café', 'cafe', 'lanchei'];
    return words.any(q.contains);
  }

  static NutriAIAnswer _estimateFood(String original, NutriAIContext context) {
    final q = original.toLowerCase();

    int kcal = 0;
    int protein = 0;
    final items = <String>[];

    void add(String item, int c, int p) {
      kcal += c;
      protein += p;
      items.add(item);
    }

    if (q.contains('ovo')) {
      final n = _numberBefore(q, 'ovo');
      add('$n ovo(s)', n * 78, n * 6);
    }

    if (q.contains('pão') || q.contains('pao')) {
      final n = _numberBeforeAny(q, ['pão', 'pao']);
      add('$n pão/pães', n * 140, n * 5);
    }

    if (q.contains('café com leite') || q.contains('cafe com leite')) add('café com leite', 90, 5);
    else if (q.contains('café') || q.contains('cafe')) add('café', 10, 0);

    if (q.contains('arroz')) add('arroz', 220, 4);
    if (q.contains('feijão') || q.contains('feijao')) add('feijão', 120, 7);
    if (q.contains('frango')) add('frango', 250, 38);
    if (q.contains('carne')) add('carne', 300, 32);
    if (q.contains('whey')) add('whey', 120, 24);
    if (q.contains('banana')) add('banana', 90, 1);
    if (q.contains('iogurte')) add('iogurte', 120, 8);
    if (q.contains('pizza')) {
      final n = _numberBeforeAny(q, ['fatia', 'fatias', 'pedaço', 'pedaco']);
      add('$n fatia(s) de pizza', n * 310, n * 12);
    }
    if (q.contains('hambúrguer') || q.contains('hamburguer') || q.contains('lanche')) add('hambúrguer/lanche', 700, 35);

    if (kcal == 0) {
      kcal = 300;
      protein = 10;
      items.add('estimativa genérica');
    }

    final availableAfter = context.day.availableCalories - kcal;

    return NutriAIAnswer(
      title: 'Refeição estimada',
      estimatedCalories: kcal,
      estimatedProtein: protein,
      canRegisterMeal: true,
      message: 'Detectei: ${items.join(', ')}. Estimativa: $kcal kcal e $protein g de proteína. Depois de registrar, você ficará com aproximadamente $availableAfter kcal disponíveis hoje.',
    );
  }

  static int _numberBefore(String text, String word) {
    final regex = RegExp('(\\d+)\\s+' + RegExp.escape(word));
    final match = regex.firstMatch(text);
    if (match != null) return int.tryParse(match.group(1) ?? '') ?? 1;
    return 1;
  }

  static int _numberBeforeAny(String text, List<String> words) {
    for (final word in words) {
      final regex = RegExp('(\\d+)\\s+' + RegExp.escape(word));
      final match = regex.firstMatch(text);
      if (match != null) return int.tryParse(match.group(1) ?? '') ?? 1;
    }
    return 1;
  }
}
