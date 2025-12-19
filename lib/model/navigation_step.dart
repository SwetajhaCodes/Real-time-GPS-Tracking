import 'package:latlong2/latlong.dart';

class NavigationStep {
  final String instruction;
  final LatLng point;

  NavigationStep({
    required this.instruction,
    required this.point,
  });
}
