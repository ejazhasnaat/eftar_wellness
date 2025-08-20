enum Units { metric, imperial }

enum Sex { male, female, preferNot }

enum GoalPrimary {
  weightLoss,
  weightGain,
  stayFit,
  medicalManagement,
  other, // new
}

enum ProfileStatus { draft, pending, approved }

class Activity {
  final int minutesPerWeek;
  final int strengthDays;

  const Activity({this.minutesPerWeek = 0, this.strengthDays = 0});

  Activity copyWith({int? minutesPerWeek, int? strengthDays}) => Activity(
        minutesPerWeek: minutesPerWeek ?? this.minutesPerWeek,
        strengthDays: strengthDays ?? this.strengthDays,
      );

  Map<String, dynamic> toJson() => {
        'minutesPerWeek': minutesPerWeek,
        'strengthDays': strengthDays,
      };

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        minutesPerWeek: j['minutesPerWeek'] ?? 0,
        strengthDays: j['strengthDays'] ?? 0,
      );
}

class Habits {
  final int hydrationCups;
  // Other fields retained (non-destructive) but not shown in UI currently
  final int fastFood;
  final int fruits;
  final int veggies;
  final int sugary;
  final bool cooksAtHome;
  final String snacks;

  const Habits({
    this.hydrationCups = 0,
    this.fastFood = 0,
    this.fruits = 0,
    this.veggies = 0,
    this.sugary = 0,
    this.cooksAtHome = false,
    this.snacks = '',
  });

  Habits copyWith({
    int? hydrationCups,
    int? fastFood,
    int? fruits,
    int? veggies,
    int? sugary,
    bool? cooksAtHome,
    String? snacks,
  }) =>
      Habits(
        hydrationCups: hydrationCups ?? this.hydrationCups,
        fastFood: fastFood ?? this.fastFood,
        fruits: fruits ?? this.fruits,
        veggies: veggies ?? this.veggies,
        sugary: sugary ?? this.sugary,
        cooksAtHome: cooksAtHome ?? this.cooksAtHome,
        snacks: snacks ?? this.snacks,
      );

  Map<String, dynamic> toJson() => {
        'hydrationCups': hydrationCups,
        'fastFood': fastFood,
        'fruits': fruits,
        'veggies': veggies,
        'sugary': sugary,
        'cooksAtHome': cooksAtHome,
        'snacks': snacks,
      };

  factory Habits.fromJson(Map<String, dynamic> j) => Habits(
        hydrationCups: j['hydrationCups'] ?? 0,
        fastFood: j['fastFood'] ?? 0,
        fruits: j['fruits'] ?? 0,
        veggies: j['veggies'] ?? 0,
        sugary: j['sugary'] ?? 0,
        cooksAtHome: j['cooksAtHome'] ?? false,
        snacks: j['snacks'] ?? '',
      );
}

class UserWellnessProfile {
  final Units units;
  final Sex? sex;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;

  @Deprecated('No longer collected in UI; retained for backward compatibility.')
  final double? waistCm;

  final GoalPrimary? goalPrimary;
  final String? goalOther; // new: detail when goalPrimary == other

  // Time horizon removed from UI. Keep field if it existed before—omit here for simplicity.

  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> intolerances;
  final List<String> dietPreferences;

  final Habits habits;
  final Activity activity;
  final double? sleepHours;

  final String? photoPath;

  final DateTime? submittedAt;
  final ProfileStatus status;

  const UserWellnessProfile({
    this.units = Units.metric,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.waistCm, // deprecated but kept
    this.goalPrimary,
    this.goalOther,
    this.medicalConditions = const [],
    this.allergies = const [],
    this.intolerances = const [],
    this.dietPreferences = const [],
    this.habits = const Habits(),
    this.activity = const Activity(),
    this.sleepHours,
    this.photoPath,
    this.submittedAt,
    this.status = ProfileStatus.draft,
  });

  UserWellnessProfile copyWith({
    Units? units,
    Sex? sex,
    double? heightCm,
    double? weightKg,
    double? bmi,
    double? waistCm,
    GoalPrimary? goalPrimary,
    String? goalOther,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? intolerances,
    List<String>? dietPreferences,
    Habits? habits,
    Activity? activity,
    double? sleepHours,
    String? photoPath,
    DateTime? submittedAt,
    ProfileStatus? status,
  }) {
    return UserWellnessProfile(
      units: units ?? this.units,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      waistCm: waistCm ?? this.waistCm,
      goalPrimary: goalPrimary ?? this.goalPrimary,
      goalOther: goalOther ?? this.goalOther,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      intolerances: intolerances ?? this.intolerances,
      dietPreferences: dietPreferences ?? this.dietPreferences,
      habits: habits ?? this.habits,
      activity: activity ?? this.activity,
      sleepHours: sleepHours ?? this.sleepHours,
      photoPath: photoPath ?? this.photoPath,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
    );
  }

  static double? calcBmi({double? heightCm, double? weightKg}) {
    if (heightCm == null || heightCm <= 0 || weightKg == null || weightKg <= 0)
      return null;
    final hM = heightCm / 100.0;
    return weightKg / (hM * hM);
  }

  Map<String, dynamic> toJson() => {
        'units': units.name,
        'sex': sex?.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'bmi': bmi,
        'waistCm': waistCm,
        'goalPrimary': goalPrimary?.name,
        'goalOther': goalOther,
        'medicalConditions': medicalConditions,
        'allergies': allergies,
        'intolerances': intolerances,
        'dietPreferences': dietPreferences,
        'habits': habits.toJson(),
        'activity': activity.toJson(),
        'sleepHours': sleepHours,
        'photoPath': photoPath,
        'submittedAt': submittedAt?.toIso8601String(),
        'status': status.name,
      };

  factory UserWellnessProfile.fromJson(Map<String, dynamic> j) =>
      UserWellnessProfile(
        units: Units.values.firstWhere(
            (e) => e.name == (j['units'] ?? 'metric'),
            orElse: () => Units.metric),
        sex: (j['sex'] == null)
            ? null
            : Sex.values.firstWhere((e) => e.name == j['sex']),
        heightCm: (j['heightCm'] as num?)?.toDouble(),
        weightKg: (j['weightKg'] as num?)?.toDouble(),
        bmi: (j['bmi'] as num?)?.toDouble(),
        waistCm: (j['waistCm'] as num?)?.toDouble(),
        goalPrimary: (j['goalPrimary'] == null)
            ? null
            : GoalPrimary.values.firstWhere((e) => e.name == j['goalPrimary'],
                orElse: () => GoalPrimary.stayFit),
        goalOther: j['goalOther'] as String?,
        medicalConditions:
            (j['medicalConditions'] as List?)?.cast<String>() ?? const [],
        allergies: (j['allergies'] as List?)?.cast<String>() ?? const [],
        intolerances: (j['intolerances'] as List?)?.cast<String>() ?? const [],
        dietPreferences:
            (j['dietPreferences'] as List?)?.cast<String>() ?? const [],
        habits: j['habits'] == null
            ? const Habits()
            : Habits.fromJson(j['habits'] as Map<String, dynamic>),
        activity: j['activity'] == null
            ? const Activity()
            : Activity.fromJson(j['activity'] as Map<String, dynamic>),
        sleepHours: (j['sleepHours'] as num?)?.toDouble(),
        photoPath: j['photoPath'] as String?,
        submittedAt: j['submittedAt'] == null
            ? null
            : DateTime.tryParse(j['submittedAt']),
        status: ProfileStatus.values.firstWhere(
          (e) => e.name == (j['status'] ?? 'draft'),
          orElse: () => ProfileStatus.draft,
        ),
      );
}
