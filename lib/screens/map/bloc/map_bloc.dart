import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:uuid/uuid.dart';
import 'package:famai/services/map_service.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapService _mapService = MapService();
  final Uuid _uuid = const Uuid();
  
  MapBloc() : super(const MapState()) {
    on<LoadMap>(_onLoadMap);
    on<MapTypeChanged>(_onMapTypeChanged);
    on<DrawingToolSelected>(_onDrawingToolSelected);
    on<PointAdded>(_onPointAdded);
    on<ShapeTapped>(_onShapeTapped);
    on<EnterEditMode>(_onEnterEditMode);
    on<ExitEditMode>(_onExitEditMode);
    on<DeleteSelectedShape>(_onDeleteSelectedShape);
    on<SaveChanges>(_onSaveChanges);
  }

  void _onLoadMap(LoadMap event, Emitter<MapState> emit) async {
    await emit.forEach(
      _mapService.getFarmMap(),
      onData: (mapData) {
        return state.copyWith(
          polygons: mapData['polygons'] as Set<Polygon>,
          polylines: mapData['polylines'] as Set<Polyline>,
          markers: mapData['markers'] as Set<Marker>,
        );
      },
    );
  }

  void _onMapTypeChanged(MapTypeChanged event, Emitter<MapState> emit) {
    emit(state.copyWith(mapType: event.mapType));
  }

  void _onDrawingToolSelected(DrawingToolSelected event, Emitter<MapState> emit) {
    emit(state.copyWith(selectedTool: event.tool, currentDrawingPoints: []));
  }

  void _onPointAdded(PointAdded event, Emitter<MapState> emit) {
    if (state.isEditing && state.selectedShapeId != null) {
      // Logic to add a point to an existing shape will go here
    } else {
      final newPoints = List<LatLng>.from(state.currentDrawingPoints)..add(event.point);
      emit(state.copyWith(currentDrawingPoints: newPoints));
    }
  }

  void _onShapeTapped(ShapeTapped event, Emitter<MapState> emit) {
    final shapeId = event.shapeId;
    double? area;
    final polygon = state.polygons.where((p) => p.polygonId.value == shapeId).firstOrNull;
    if (polygon != null) {
      area = maps_toolkit.SphericalUtil.computeArea(polygon.points.map((p) => maps_toolkit.LatLng(p.latitude, p.longitude)).toList()).toDouble();
    }
    emit(state.copyWith(selectedShapeId: shapeId, selectedArea: area));
  }

  void _onEnterEditMode(EnterEditMode event, Emitter<MapState> emit) {
    emit(state.copyWith(isEditing: true));
  }

  void _onExitEditMode(ExitEditMode event, Emitter<MapState> emit) {
    emit(state.copyWith(isEditing: false, selectedShapeId: null, selectedArea: null));
  }

  void _onDeleteSelectedShape(DeleteSelectedShape event, Emitter<MapState> emit) async {
    if (state.selectedShapeId == null) return;

    final shapeId = state.selectedShapeId!;
    Set<Polygon> newPolygons = Set.from(state.polygons);
    Set<Polyline> newPolylines = Set.from(state.polylines);
    Set<Marker> newMarkers = Set.from(state.markers);

    if (newPolygons.any((p) => p.polygonId.value == shapeId)) {
      await _mapService.deleteShape('polygons', shapeId);
    } else if (newPolylines.any((p) => p.polylineId.value == shapeId)) {
      await _mapService.deleteShape('polylines', shapeId);
    } else if (newMarkers.any((m) => m.markerId.value == shapeId)) {
      await _mapService.deleteShape('markers', shapeId);
    }

    emit(state.copyWith(selectedShapeId: null, selectedArea: null));
  }

  void _onSaveChanges(SaveChanges event, Emitter<MapState> emit) async {
    switch (state.selectedTool) {
      case DrawingTool.polygon:
        final id = _uuid.v4();
        final area = maps_toolkit.SphericalUtil.computeArea(state.currentDrawingPoints.map((p) => maps_toolkit.LatLng(p.latitude, p.longitude)).toList()).toDouble();
        await _mapService.saveShape('polygons', id, state.currentDrawingPoints, area: area);
        // No need to create the polygon here, it will be created by the stream from Firestore

        break;
      case DrawingTool.polyline:
        final id = _uuid.v4();
        await _mapService.saveShape('polylines', id, state.currentDrawingPoints);
        break;
      case DrawingTool.marker:
        final id = _uuid.v4();
        await _mapService.saveShape('markers', id, [state.currentDrawingPoints.last]);
        break;
      case DrawingTool.none:
        break;
    }
    emit(state.copyWith(currentDrawingPoints: [], selectedTool: DrawingTool.none));
  }
}
