part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class LoadMap extends MapEvent {}

class MapTypeChanged extends MapEvent {
  final MapType mapType;
  const MapTypeChanged(this.mapType);
  @override
  List<Object> get props => [mapType];
}

class DrawingToolSelected extends MapEvent {
  final DrawingTool tool;
  const DrawingToolSelected(this.tool);
  @override
  List<Object> get props => [tool];
}

class PointAdded extends MapEvent {
  final LatLng point;
  const PointAdded(this.point);
  @override
  List<Object> get props => [point];
}

class ShapeTapped extends MapEvent {
  final String shapeId;
  const ShapeTapped(this.shapeId);
  @override
  List<Object> get props => [shapeId];
}

class EnterEditMode extends MapEvent {}

class ExitEditMode extends MapEvent {}

class DeleteSelectedShape extends MapEvent {}

class SaveChanges extends MapEvent {}
