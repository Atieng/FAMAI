import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference _getFarmMapRef() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    return _firestore.collection('users').doc(user.uid).collection('farm_maps').doc('main_map');
  }

  Future<void> saveShape(String type, String id, List<LatLng> points, {double? area}) async {
    final pointsData = points.map((p) => GeoPoint(p.latitude, p.longitude)).toList();
    await _getFarmMapRef().collection(type).doc(id).set({
      'points': pointsData,
      'area': area,
    });
  }

  Future<void> deleteShape(String type, String id) async {
    await _getFarmMapRef().collection(type).doc(id).delete();
  }

  Stream<Map<String, Set<dynamic>>> getFarmMap() {
    return _getFarmMapRef().snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final polygons = (data['polygons'] as List? ?? []).map((p) => _createPolygon(p)).toSet();
      final polylines = (data['polylines'] as List? ?? []).map((p) => _createPolyline(p)).toSet();
      final markers = (data['markers'] as List? ?? []).map((p) => _createMarker(p)).toSet();
      return {'polygons': polygons, 'polylines': polylines, 'markers': markers};
    });
  }

  Polygon _createPolygon(Map<String, dynamic> data) {
    final points = (data['points'] as List).map((p) => LatLng(p.latitude, p.longitude)).toList();
    return Polygon(
      polygonId: PolygonId(data['id']),
      points: points,
      fillColor: Colors.green.withOpacity(0.3),
      strokeColor: Colors.green,
      strokeWidth: 2,
      consumeTapEvents: true,
    );
  }

  Polyline _createPolyline(Map<String, dynamic> data) {
    final points = (data['points'] as List).map((p) => LatLng(p.latitude, p.longitude)).toList();
    return Polyline(
      polylineId: PolylineId(data['id']),
      points: points,
      color: Colors.blue,
      width: 3,
      consumeTapEvents: true,
    );
  }

  Marker _createMarker(Map<String, dynamic> data) {
    final point = data['points'][0];
    return Marker(
      markerId: MarkerId(data['id']),
      position: LatLng(point.latitude, point.longitude),
    );
  }
}
