import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view_model/location_viewmodel.dart';

class StatusWidget extends StatelessWidget {
  final LocationViewModel vm = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${vm.latitude.value.toStringAsFixed(6)}'),
            Text('Longitude: ${vm.longitude.value.toStringAsFixed(6)}'),
            Text('Tracking: ${vm.isTracking.value ? "ON" : "OFF"}'),
          ],
        ),
      ),
    );
  }
}
