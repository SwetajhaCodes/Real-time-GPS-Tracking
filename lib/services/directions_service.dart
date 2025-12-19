import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class DirectionsService {
  final Dio _dio = Dio();
  final String apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImYwOTY0NDE1ZTQ1MTRlYWI5ZjNiNmZiNTA5MDRjYTZmIiwiaCI6Im11cm11cjY0In0=';

  Future<Map<String, dynamic>> getRoute(
      LatLng start, LatLng end) async {
    final res = await _dio.post(
      'https://api.openrouteservice.org/v2/directions/driving-car',
      options: Options(headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      }),
      data: {
        "coordinates": [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude]
        ]
      },
    );
    return res.data;
  }
}
