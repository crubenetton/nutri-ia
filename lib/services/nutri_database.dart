import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NutriDatabase {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não logado');
    return user.uid;
  }

  String get todayKey {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  DocumentReference<Map<String, dynamic>> get userDoc => _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> mealsCollection() => userDoc.collection('meals');
  CollectionReference<Map<String, dynamic>> exercisesCollection() => userDoc.collection('exercises');
  CollectionReference<Map<String, dynamic>> medicinesCollection() => userDoc.collection('medicines');
  CollectionReference<Map<String, dynamic>> bodyProgressCollection() => userDoc.collection('bodyProgress');

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() => userDoc.snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> mealsTodayStream() {
    return mealsCollection().where('dateKey', isEqualTo: todayKey).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> exercisesTodayStream() {
    return exercisesCollection().where('dateKey', isEqualTo: todayKey).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> mealsLastDaysStream({int days = 7}) {
    final now = DateTime.now();
    final keys = List.generate(days, (index) {
      final date = now.subtract(Duration(days: index));
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '${date.year}-$month-$day';
    });

    return mealsCollection().where('dateKey', whereIn: keys).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> exercisesLastDaysStream({int days = 7}) {
    final now = DateTime.now();
    final keys = List.generate(days, (index) {
      final date = now.subtract(Duration(days: index));
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '${date.year}-$month-$day';
    });

    return exercisesCollection().where('dateKey', whereIn: keys).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> medicinesStream() => medicinesCollection().snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> bodyProgressStream() => bodyProgressCollection().snapshots();

  Future<void> addMeal({
    required String name,
    required int calories,
    required int protein,
  }) async {
    final now = DateTime.now();

    await mealsCollection().add({
      'name': name.trim(),
      'calories': calories,
      'protein': protein,
      'createdAt': Timestamp.fromDate(now),
      'dateKey': todayKey,
      'source': 'manual_or_ai_local',
    });
  }

  Future<void> deleteMeal(String mealId) async {
    await mealsCollection().doc(mealId).delete();
  }

  Future<void> addExercise({
    required String name,
    required int calories,
    required int minutes,
  }) async {
    final now = DateTime.now();

    await exercisesCollection().add({
      'name': name.trim(),
      'calories': calories,
      'minutes': minutes,
      'createdAt': Timestamp.fromDate(now),
      'dateKey': todayKey,
      'source': 'manual',
    });
  }

  Future<void> deleteExercise(String exerciseId) async {
    await exercisesCollection().doc(exerciseId).delete();
  }

  Future<void> addWater(int ml) async {
    final now = DateTime.now();

    await userDoc.set({
      'waterMlToday': FieldValue.increment(ml),
      'waterDateKey': todayKey,
      'waterUpdatedAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  Future<void> resetWaterToday() async {
    final now = DateTime.now();

    await userDoc.set({
      'waterMlToday': 0,
      'waterDateKey': todayKey,
      'waterUpdatedAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  Future<void> addMedicine({
    required String name,
    required String dose,
    required String time,
  }) async {
    await medicinesCollection().add({
      'name': name.trim(),
      'dose': dose.trim(),
      'time': time.trim(),
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'active': true,
      'lastTakenAt': null,
    });
  }

  Future<void> markMedicineTaken(String medicineId) async {
    await medicinesCollection().doc(medicineId).set({
      'lastTakenAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Future<void> deleteMedicine(String medicineId) async {
    await medicinesCollection().doc(medicineId).delete();
  }

  Future<void> addBodyProgress({
    required double weightKg,
    required double waistCm,
    required String notes,
    String photoUrl = '',
  }) async {
    final now = DateTime.now();

    await bodyProgressCollection().add({
      'weightKg': weightKg,
      'waistCm': waistCm,
      'notes': notes.trim(),
      'photoUrl': photoUrl.trim(),
      'createdAt': Timestamp.fromDate(now),
      'dateKey': todayKey,
    });

    await userDoc.set({
      'weightKg': weightKg,
      'waistCm': waistCm,
      'lastProgressAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  Future<void> deleteBodyProgress(String progressId) async {
    await bodyProgressCollection().doc(progressId).delete();
  }

  Future<void> saveSmartProfile(Map<String, dynamic> data) async {
    await userDoc.set({
      ...data,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Future<void> completeWizard(Map<String, dynamic> data) async {
    final now = DateTime.now();

    await userDoc.set({
      ...data,
      'onboardingCompleted': true,
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));

    final medicinesText = (data['medicinesText'] ?? '').toString();
    if (medicinesText.trim().isNotEmpty) {
      await medicinesCollection().add({
        'name': medicinesText.trim(),
        'dose': 'Conferir dose',
        'time': 'Conferir horário',
        'createdAt': Timestamp.fromDate(now),
        'active': true,
      });
    }
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required String sex,
    required double weightKg,
    required double heightCm,
    required String goal,
    required String likes,
    required String dislikes,
  }) async {
    await userDoc.set({
      'name': name.trim(),
      'age': age,
      'sex': sex,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'goal': goal.trim(),
      'likesText': likes.trim(),
      'dislikesText': dislikes.trim(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Future<void> updateProfileFull({
    required String name,
    required int age,
    required String sex,
    required double weightKg,
    required double heightCm,
    required String goal,
    required String likes,
    required String drinks,
    required String dislikes,
    required String trainingRoutine,
    required String mealsTimes,
    required int bmr,
    required int dailyGoalCalories,
    required double waterGoalLiters,
    required int proteinGoalGrams,
    required double bmi,
  }) async {
    await userDoc.set({
      'name': name.trim(),
      'age': age,
      'sex': sex,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'goal': goal.trim(),
      'likesText': likes.trim(),
      'drinksText': drinks.trim(),
      'dislikesText': dislikes.trim(),
      'trainingRoutine': trainingRoutine.trim(),
      'mealsTimes': mealsTimes.trim(),
      'bmr': bmr,
      'dailyGoalCalories': dailyGoalCalories,
      'waterGoalLiters': waterGoalLiters,
      'proteinGoalGrams': proteinGoalGrams,
      'bmi': bmi,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }
}
