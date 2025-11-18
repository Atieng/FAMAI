import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famai/models/planting_plan_model.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<PlantingPlan>> getPlantingPlans() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planting_plans')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PlantingPlan.fromFirestore(doc)).toList());
  }

  Future<void> addPlantingPlan(PlantingPlan plan) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planting_plans')
        .add(plan.toFirestore());
  }

  Future<void> updatePlantingPlan(PlantingPlan plan) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planting_plans')
        .doc(plan.id)
        .update(plan.toFirestore());
  }

  Future<void> deletePlantingPlan(String planId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planting_plans')
        .doc(planId)
        .delete();
  }
}
