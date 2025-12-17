import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationViewModel extends GetxController {
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  RxBool isLoading = true.obs;
  RxBool isTracking = false.obs;

  RxString error = ''.obs;

  StreamSubscription<Position>? _positionStream;
  List<LatLng> routePoints = <LatLng>[].obs;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
  );

  @override
  void onInit() {
    super.onInit();
    initLocation();
  }

  Future<void> initLocation() async {
    isLoading.value = true;

    final allowed = await _checkPermissions();
    if (!allowed) {
      isLoading.value = false;
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    _updatePosition(pos);

    isLoading.value = false;
  }

  Future<bool> _checkPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      error.value = 'GPS is OFF';
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      error.value = 'Location permission permanently denied';
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  void startTracking() async {
    if (isTracking.value) return;

    final allowed = await _checkPermissions();
    if (!allowed) return;

    isTracking.value = true;

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _updatePosition(position);
          },
        );
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    isTracking.value = false;
  }

  void _updatePosition(Position pos) {
    latitude.value = pos.latitude;
    longitude.value = pos.longitude;
    routePoints.add(LatLng(pos.latitude, pos.longitude));
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
}
