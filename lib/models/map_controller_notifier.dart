import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapControllerProvider with ChangeNotifier {
  final Map<int, GoogleMapController> _controllers = {};

  void setController(int deliveryId, GoogleMapController controller) {
    _controllers[deliveryId] = controller;
    notifyListeners();
  }

  GoogleMapController? getController(int deliveryId) {
    return _controllers[deliveryId];
  }

  void moveCamera(int deliveryId, LatLng position) {
    final controller = _controllers[deliveryId];
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newLatLng(position));
    } else {
      debugPrint("No controller found for deliveryId $deliveryId");
    }
  }

  void removeController(int deliveryId) {
    _controllers.remove(deliveryId);
    notifyListeners();
  }
}