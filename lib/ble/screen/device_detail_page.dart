import 'package:ble_test3/ble/model/model.dart';
import 'package:ble_test3/ble/screen/device_connect_tab.dart';
import 'package:ble_test3/ble/screen/log_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../provider/flutter_ble.dart';

class DeviceDetailPage extends StatelessWidget {
  static const path = '/list/detail';

  const DeviceDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterBle _provider = context.watch<FlutterBle>();
    final DiscoveredDevice? dis = _provider.currentDevice;
    final DeviceModel device = DeviceModel(
      deviceId: dis?.id ?? "",
      serviceUuids: dis?.serviceUuids ?? [],
      name: dis?.name ?? '',
      connectionStatus: _provider.state,
    );
    return DeviceDetailView(
      deviceModel: device,
      onWillPop: () async {
        await _provider.disconnect(id: device.deviceId);
        return true;
      },
    );
  }
}

class DeviceDetailView extends StatelessWidget {
  final Future<bool> Function()? onWillPop;
  final DeviceModel deviceModel;

  const DeviceDetailView({
    required this.deviceModel,
    required this.onWillPop,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(deviceModel.name),
            backgroundColor: Colors.indigo[400],
            elevation: 0,
            bottom: TabBar(
              labelColor: Colors.indigo[400],
              unselectedLabelColor: Colors.white,
              indicator: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  icon: Icon(
                    Icons.bluetooth_connected,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.find_in_page_sharp,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DeviceConnectPage(),
              DeviceLogPage(),
            ],
          ),
        ),
      ),
    );
  }
}
