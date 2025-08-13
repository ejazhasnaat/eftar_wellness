enum ExpertKind { dietitian, fitnessExpert, healthyMealsProvider }

extension ExpertKindX on ExpertKind {
  String get label {
    switch (this) {
      case ExpertKind.dietitian: return 'Dietitian';
      case ExpertKind.fitnessExpert: return 'Fitness Expert';
      case ExpertKind.healthyMealsProvider: return 'Healthy Meals Provider';
    }
  }
  String get nameKey => name; // stable key for storage
}

