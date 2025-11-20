part of 'map_bloc.dart';

enum DrawingTool { none, polygon, polyline, marker }

class MapState extends Equatable {
  final MapType mapType;
  final DrawingTool selectedTool;
  final Set<Polygon> polygons;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  final List<LatLng> currentDrawingPoints;
  final String? selectedShapeId;
  final bool isEditing;
  final double? selectedArea;

  const MapState({
    this.mapType = MapType.normal,
    this.selectedTool = DrawingTool.none,
    this.polygons = const {},
    this.polylines = const {},
    this.markers = const {},
    this.currentDrawingPoints = const [],
    this.selectedShapeId,
    this.isEditing = false,
    this.selectedArea,
  });

  MapState copyWith({
    MapType? mapType,
    DrawingTool? selectedTool,
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Marker>? markers,
    List<LatLng>? currentDrawingPoints,
    String? selectedShapeId,
    bool? isEditing,
    double? selectedArea,
  }) {
    return MapState(
      mapType: mapType ?? this.mapType,
      selectedTool: selectedTool ?? this.selectedTool,
      polygons: polygons ?? this.polygons,
      polylines: polylines ?? this.polylines,
      markers: markers ?? this.markers,
      currentDrawingPoints: currentDrawingPoints ?? this.currentDrawingPoints,
      selectedShapeId: selectedShapeId ?? this.selectedShapeId,
      isEditing: isEditing ?? this.isEditing,
      selectedArea: selectedArea ?? this.selectedArea,
    );
  }

  @override
  List<Object?> get props => [
        mapType,
        selectedTool,
        polygons,
        polylines,
        markers,
        currentDrawingPoints,
        selectedShapeId,
        isEditing,
        selectedArea,
      ];
}
