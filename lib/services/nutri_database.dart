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

  DocumentReference<Map<String, dynamic>> get userDoc => _db.collection('users').doc(uid);

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() => userDoc.snapshots();

  CollectionReference<Map<String, dynamic>> mealsCollection() => userDoc.collection('meals');
  CollectionReference<Map<String, dynamic>> medicinesCollection() => userDoc.collection('medicines');
  CollectionReference<Map<String, dynamic>> exercisesCollection() => userDoc.collection('exercises');
  CollectionReference<Map<String, dynamic>> bodyProgressCollection() => userDoc.collection('bodyProgress');

  Stream<QuerySnapshot<Map<String, dynamic>>> mealsTodayStream() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return mealsCollection()
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> mealsLastDaysStream({int days = 7}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    return mealsCollection()
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> exercisesTodayStream() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return exercisesCollection()
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> exercisesLastDaysStream({int days = 7}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    return exercisesCollection()
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> medicinesStream() {
    return medicinesCollection().orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> bodyProgressStream() {
    return bodyProgressCollection().orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addMeal({
    required String name,
    required int calories,
    required int protein,
  }) async {
    await mealsCollection().add({
      'name': name.trim(),
      'calories': calories,
      'protein': protein,
      'createdAt': FieldValue.serverTimestamp(),
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
    await exercisesCollection().add({
      'name': name.trim(),
      'calories': calories,
      'minutes': minutes,
      'createdAt': FieldValue.serverTimestamp(),
      'source': 'manual',
    });
  }

  Future<void> deleteExercise(String exerciseId) async {
    await exercisesCollection().doc(exerciseId).delete();
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
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
      'lastTakenAt': null,
    });
  }

  Future<void> markMedicineTaken(String medicineId) async {
    await medicinesCollection().doc(medicineId).set({
      'lastTakenAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteMedicine(String medicineId) async {
    await medicinesCollection().doc(medicineId).delete();
  }

  Future<void> addWater(int ml) async {
    await userDoc.set({
      'waterMlToday': FieldValue.increment(ml),
      'waterUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetWaterToday() async {
    await userDoc.set({
      'waterMlToday': 0,
      'waterUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> completeWizard(Map<String, dynamic> data) async {
    await userDoc.set({
      ...data,
      'onboardingCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final medicinesText = (data['medicinesText'] ?? '').toString();
    if (medicinesText.trim().isNotEmpty) {
      await medicinesCollection().add({
        'name': medicinesText.trim(),
        'dose': 'Conferir dose',
        'time': 'Conferir horário',
        'createdAt': FieldValue.serverTimestamp(),
        'active': true,
      });
    }
  }

  Future<void> saveSmartProfile(Map<String, dynamic> data) async {
    await userDoc.set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addBodyProgress({
    required double weightKg,
    required double waistCm,
    required String notes,
    String photoUrl = '',
  }) async {
    await bodyProgressCollection().add({
      'weightKg': weightKg,
      'waistCm': waistCm,
      'notes': notes.trim(),
      'photoUrl': photoUrl.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await userDoc.set({
      'weightKg': weightKg,
      'waistCm': waistCm,
      'lastProgressAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteBodyProgress(String progressId) async {
    await bodyProgressCollection().doc(progressId).delete();
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
      'updatedAt': FieldValue.serverTimestamp(),
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
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
