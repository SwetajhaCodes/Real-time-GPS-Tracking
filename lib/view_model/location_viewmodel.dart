// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:latlong2/latlong.dart';
// import '../model/navigation_step.dart';
//
// final locationProvider =
// StateNotifierProvider<LocationViewModel, LocationState>(
//         (ref) => LocationViewModel());
//
// class LocationState {
//   final bool isTracking;
//   final int stepIndex;
//   final LatLng currentLocation;
//   final List<LatLng> route;
//   final List<NavigationStep> steps;
//
//   LocationState({
//     this.isTracking = false,
//     this.stepIndex = 0,
//     required this.currentLocation,
//     this.route = const [],
//     this.steps = const [],
//   });
//
//   LocationState copyWith({
//     bool? isTracking,
//     int? stepIndex,
//     LatLng? currentLocation,
//     List<LatLng>? route,
//     List<NavigationStep>? steps,
//   }) {
//     return LocationState(
//       isTracking: isTracking ?? this.isTracking,
//       stepIndex: stepIndex ?? this.stepIndex,
//       currentLocation: currentLocation ?? this.currentLocation,
//       route: route ?? this.route,
//       steps: steps ?? this.steps,
//     );
//   }
// }
//
// class LocationViewModel extends StateNotifier<LocationState> {
//   LocationViewModel()
//       : super(
//     LocationState(
//       currentLocation: const LatLng(28.6139, 77.2090), // Delhi demo
//     ),
//   );
//
//   Timer? _timer;
//
//   void startDemoNavigation() {
//     final demoRoute = [
//       const LatLng(28.6139, 77.2090),
//       const LatLng(28.6145, 77.2095),
//       const LatLng(28.6150, 77.2102),
//       const LatLng(28.6155, 77.2110),
//       const LatLng(28.6160, 77.2120),
//     ];
//
//     final demoSteps = [
//       NavigationStep(
//         instruction: "Continue straight",
//         point: demoRoute[1],
//       ),
//       NavigationStep(
//         instruction: "Turn left",
//         point: demoRoute[2],
//       ),
//       NavigationStep(
//         instruction: "Continue straight",
//         point: demoRoute[3],
//       ),
//       NavigationStep(
//         instruction: "Turn right",
//         point: demoRoute[4],
//       ),
//       NavigationStep(
//         instruction: "You have arrived",
//         point: demoRoute[4],
//       ),
//     ];
//
//     state = state.copyWith(
//       isTracking: true,
//       stepIndex: 0,
//       route: demoRoute,
//       steps: demoSteps,
//     );
//
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (state.stepIndex < state.steps.length - 1) {
//         state = state.copyWith(stepIndex: state.stepIndex + 1);
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   void stopTracking() {
//     _timer?.cancel();
//     state = state.copyWith(isTracking: false);
//   }
// }


import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/directions_service.dart';
import '../model/navigation_step.dart';

final locationProvider =
StateNotifierProvider<LocationViewModel, LocationState>(
        (ref) => LocationViewModel());

class LocationState {
  final bool isTracking;
  final LatLng? currentLocation;
  final List<LatLng> route;
  final List<NavigationStep> steps;
  final int stepIndex;

  LocationState({
    this.isTracking = false,
    this.currentLocation,
    this.route = const [],
    this.steps = const [],
    this.stepIndex = 0,
  });

  LocationState copyWith({
    bool? isTracking,
    LatLng? currentLocation,
    List<LatLng>? route,
    List<NavigationStep>? steps,
    int? stepIndex,
  }) {
    return LocationState(
      isTracking: isTracking ?? this.isTracking,
      currentLocation: currentLocation ?? this.currentLocation,
      route: route ?? this.route,
      steps: steps ?? this.steps,
      stepIndex: stepIndex ?? this.stepIndex,
    );
  }
}

class LocationViewModel extends StateNotifier<LocationState> {
  LocationViewModel() : super(LocationState());

  final LocationService _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService();

  StreamSubscription? _sub;

  // 🔴 DEMO CODE (COMMENTED)
  // Timer? _timer;
  // void startDemoNavigation() {}

  Future<void> startTracking(LatLng destination) async {
    final granted = await _locationService.checkPermission();
    if (!granted) return;

    state = state.copyWith(isTracking: true);

    _sub = _locationService.getPositionStream().listen((pos) async {
      final current = LatLng(pos.latitude, pos.longitude);

      state = state.copyWith(
        currentLocation: current,
      );

      if (state.steps.isEmpty) {
        await _buildRoute(current, destination);
      }

      _updateStep(current);
    });
  }

  Future<void> _buildRoute(LatLng start, LatLng end) async {
    final data = await _directionsService.getRoute(start, end);

    final coords =
    data['features'][0]['geometry']['coordinates'] as List;

    final stepsData =
    data['features'][0]['properties']['segments'][0]['steps'];

    final routePoints = coords
        .map<LatLng>((c) => LatLng(c[1], c[0]))
        .toList();

    final steps = stepsData.map<NavigationStep>((s) {
      final loc = s['maneuver']['location'];
      return NavigationStep(
        instruction: s['instruction'],
        point: LatLng(loc[1], loc[0]),
      );
    }).toList();

    state = state.copyWith(route: routePoints, steps: steps);
  }

  void _updateStep(LatLng current) {
    if (state.stepIndex >= state.steps.length) return;

    const Distance distance = Distance();
    final step = state.steps[state.stepIndex];
    final meters = distance(current, step.point);

    if (meters < 20) {
      state = state.copyWith(stepIndex: state.stepIndex + 1);
    }
  }

  void stopTracking() {
    _sub?.cancel();
    state = LocationState();
  }
}
