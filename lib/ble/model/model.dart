import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceModel {
  const DeviceModel({
    required this.deviceId,
    required this.name,
    required this.serviceUuids,
    required this.connectionStatus,
  });

  final String deviceId;
  final String name;
  final List<Uuid> serviceUuids;
  final DeviceConnectionState connectionStatus;

}
