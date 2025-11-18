import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveFarmBoundary(List<LatLng> boundaryPoints) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final List<Map<String, double>> points = boundaryPoints
        .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
        .toList();

    await _firestore.collection('users').doc(user.uid).update({
      'farm_boundary': points,
    });
  }
}
