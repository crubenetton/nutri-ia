class HealthCalculator {
  static double bmr({
    required String sex,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    if (sex.toLowerCase().contains('fem')) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
  }

  static double bmi({
    required double weightKg,
    required double heightCm,
  }) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static double waterLiters({
    required double weightKg,
    double trainingExtra = 0.4,
  }) {
    return (weightKg * 35 / 1000) + trainingExtra;
  }

  static int proteinTarget({
    required double weightKg,
    String goal = '',
  }) {
    final lower = goal.toLowerCase();
    final factor = lower.contains('massa') ? 2.0 : 1.8;
    return (weightKg * factor).round();
  }

  static double activityFactor(String level) {
    final lower = level.toLowerCase();
    if (lower.contains('sedent')) return 1.2;
    if (lower.contains('leve')) return 1.375;
    if (lower.contains('moder')) return 1.55;
    if (lower.contains('intens')) return 1.725;
    return 1.375;
  }

  static int dailyGoal({
    required double bmr,
    required String goal,
    String activityLevel = 'Leve',
  }) {
    final maintenance = bmr * activityFactor(activityLevel);
    final lower = goal.toLowerCase();

    if (lower.contains('emagrecer') && lower.contains('massa')) {
      return (maintenance - 250).round();
    }
    if (lower.contains('emagrecer') || lower.contains('defini')) {
      return (maintenance - 400).round();
    }
    if (lower.contains('massa')) {
      return (maintenance + 250).round();
    }
    return maintenance.round();
  }
}
