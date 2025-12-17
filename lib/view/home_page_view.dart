import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../view_model/location_viewmodel.dart';
import '../widgets/loading_widget.dart';
import '../widgets/status_widget.dart';

class HomePageView extends StatelessWidget {
  final LocationViewModel vm = Get.put(LocationViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time GPS Tracking')),
      body: Obx(() {
        if (vm.isLoading.value) return const LoadingWidget();

        if (vm.error.isNotEmpty) {
          return Center(child: Text(vm.error.value));
        }

        return Column(
          children: [
            StatusWidget(),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(vm.latitude.value, vm.longitude.value),
                  initialZoom: 18,
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
                        points: vm.routePoints,
                        strokeWidth: 4,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(vm.latitude.value, vm.longitude.value),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: vm.isTracking.value
                    ? vm.stopTracking
                    : vm.startTracking,
                child: Text(
                  vm.isTracking.value ? 'Stop Tracking' : 'Start Tracking',
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
