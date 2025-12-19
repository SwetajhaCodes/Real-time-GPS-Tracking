// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../view_model/location_viewmodel.dart';
//
// class HomePage extends ConsumerWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(locationProvider);
//     final vm = ref.read(locationProvider.notifier);
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//             options: MapOptions(
//               initialCenter: state.currentLocation,
//               initialZoom: 16,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate:
//                 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.example.gps_tracking',
//               ),
//               PolylineLayer(
//                 polylines: [
//                   Polyline(
//                     points: state.route,
//                     strokeWidth: 5,
//                     color: Colors.blue,
//                   ),
//                 ],
//               ),
//               MarkerLayer(
//                 markers: [
//                   Marker(
//                     point: state.currentLocation,
//                     width: 40,
//                     height: 40,
//                     child: const Icon(
//                       Icons.navigation,
//                       color: Colors.red,
//                       size: 40,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//
//           // Instruction Card
//           if (state.steps.isNotEmpty)
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 12,
//               left: 16,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.black87,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     _turnIcon(state.steps[state.stepIndex].instruction),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         state.steps[state.stepIndex].instruction,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // Start / Stop Button
//           Positioned(
//             bottom: 30,
//             left: 16,
//             right: 16,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.all(18),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               onPressed:
//               state.isTracking ? vm.stopTracking : vm.startDemoNavigation,
//               child: Text(
//                 state.isTracking ? "Stop" : "Start Demo Navigation",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _turnIcon(String instruction) {
//     final text = instruction.toLowerCase();
//
//     if (text.contains("left")) {
//       return const Icon(Icons.turn_left, color: Colors.green, size: 30);
//     } else if (text.contains("right")) {
//       return const Icon(Icons.turn_right, color: Colors.green, size: 30);
//     } else if (text.contains("arrived")) {
//       return const Icon(Icons.flag, color: Colors.red, size: 30);
//     } else {
//       return const Icon(Icons.arrow_upward, color: Colors.blue, size: 30);
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../view_model/location_viewmodel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationProvider);
    final vm = ref.read(locationProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter:
              state.currentLocation ?? const LatLng(28.6139, 77.2090),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gps_tracking',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: state.route,
                    strokeWidth: 5,
                    color: Colors.blue,
                  ),
                ],
              ),
              if (state.currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: state.currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.navigation,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Instruction Card
          if (state.steps.isNotEmpty &&
              state.stepIndex < state.steps.length)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _icon(state.steps[state.stepIndex].instruction),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.steps[state.stepIndex].instruction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Start Button
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                const destination =
                LatLng(28.6160, 77.2120); // change if needed
                vm.startTracking(destination);
              },
              child: const Text("Start Navigation"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(String text) {
    text = text.toLowerCase();
    if (text.contains("left")) {
      return const Icon(Icons.turn_left, color: Colors.green);
    } else if (text.contains("right")) {
      return const Icon(Icons.turn_right, color: Colors.green);
    } else {
      return const Icon(Icons.arrow_upward, color: Colors.blue);
    }
  }
}
