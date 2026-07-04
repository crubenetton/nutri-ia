class NutriDaySummary {
  final int consumedCalories;
  final int exerciseCalories;
  final int targetCalories;
  final int proteinConsumed;
  final int proteinTarget;
  final double waterConsumedLiters;
  final double waterTargetLiters;

  const NutriDaySummary({
    required this.consumedCalories,
    required this.exerciseCalories,
    required this.targetCalories,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.waterConsumedLiters,
    required this.waterTargetLiters,
  });

  int get availableCalories => targetCalories + exerciseCalories - consumedCalories;
  int get proteinMissing => (proteinTarget - proteinConsumed).clamp(0, 999);
  double get waterMissing => (waterTargetLiters - waterConsumedLiters).clamp(0, 99);

  String get status {
    if (availableCalories >= 700) return 'Você ainda tem boa margem para comer com controle.';
    if (availableCalories >= 250) return 'Você ainda pode fazer uma refeição leve.';
    if (availableCalories >= 0) return 'Você está perto da meta. Prefira proteína leve.';
    return 'Você passou da meta. Amanhã ajustamos sem desespero.';
  }

  String get coachMessage {
    final parts = <String>[];

    if (waterMissing > 0.3) {
      parts.add('beba mais ${waterMissing.toStringAsFixed(1)} L de água');
    }

    if (proteinMissing > 15) {
      parts.add('faltam $proteinMissing g de proteína');
    }

    if (availableCalories > 500) {
      parts.add('ainda restam $availableCalories kcal');
    }

    if (parts.isEmpty) {
      return 'Excelente! Hoje você está muito bem alinhado com suas metas.';
    }

    return 'Hoje: ${parts.join(', ')}.';
  }

  String pizzaAdvice() {
    if (availableCalories >= 800) {
      return 'Pode comer pizza hoje. Até 2 ou 3 fatias cabem melhor na sua meta.';
    }
    if (availableCalories >= 450) {
      return 'Pode comer pizza, mas controle em 1 ou 2 fatias e evite exageros.';
    }
    return 'Hoje não é o melhor dia para pizza. Se quiser muito, coma pouco e compense com proteína leve.';
  }

  String dinnerSuggestion() {
    if (proteinMissing > 35) {
      return 'Para a noite, prefira frango, ovos, iogurte ou whey para bater proteína.';
    }
    if (availableCalories > 700) {
      return 'Você pode jantar bem: arroz com frango, ovos ou carne magra.';
    }
    if (availableCalories > 250) {
      return 'Faça uma janta leve: ovos, iogurte, whey ou frango sem exagero.';
    }
    return 'Hoje escolha algo bem leve e priorize água.';
  }
}
