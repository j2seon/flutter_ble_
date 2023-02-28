import 'package:ble_test3/ble/provider/flutter_ble.dart';
import 'package:ble_test3/ble/screen/device_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../common/widget.dart';

class BleListPage extends StatelessWidget {
  static const path = '/list';

  const BleListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterBle _provider = context.watch<FlutterBle>();
    return BleListView(
        scanStart: _provider.isScan ? null : _provider.startScan,
        scanStop: _provider.isScan ? _provider.scanStop : null,
        itemCount: _provider.scanData.length,
        isConnect: _provider.isConnect,
        connected: () => Navigator.of(context).pushNamed<void>(DeviceDetailPage.path),
        itemBuilder: (context, index) {
          Map<String, DiscoveredDevice> scanDevice = _provider.scanData;
          DiscoveredDevice device = scanDevice.values.toList()[index];
          // print('device.serviceUuids ${device.name} : ${device.serviceUuids}');
          return DeviceTile(
            title: device.name,
            id: device.id,
            rssi: device.rssi,
            onTap: () async{
              _provider.setDeviceIndex(index);
              await _provider.connect(id: device.id);
              Navigator.of(context).pushNamed<void>(DeviceDetailPage.path);
            },
          );
        });
  }
}

class DeviceTile extends StatelessWidget {
  final String title;
  final String id;
  final int rssi;
  final void Function() onTap;

  const DeviceTile({
    required this.title,
    required this.id,
    required this.rssi,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text("$id\nRSSI: $rssi"),
      leading: const BluetoothIcon(),
      onTap: onTap,
    );
  }
}

class BleListView extends StatefulWidget {
  final Widget Function(BuildContext, int) itemBuilder;
  final void Function({List<Uuid>? withServices})? scanStart;
  final void Function()? scanStop;
  final void Function() connected;
  final int itemCount;
  final bool isConnect;

  const BleListView(
      {required this.itemBuilder,
      required this.scanStart,
      required this.scanStop,
      required this.itemCount,
      required this.isConnect,
      required this.connected,
      Key? key})
      : super(key: key);

  @override
  State<BleListView> createState() => _BleListViewState();
}

class _BleListViewState extends State<BleListView> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.scanStart!(); //오토스캔
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Device'),
        centerTitle: true,
        actions: [
          if(widget.isConnect)
          IconButton(
            onPressed: widget.connected,
            icon: Icon(Icons.bluetooth_connected),
          ),
        ]
      ),
      body: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.scanStart,
                  child: Text('Scan'),
                ),
                ElevatedButton(
                  onPressed: widget.scanStop,
                  child: Text('Stop'),
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text('count : ${widget.itemCount.toString()}')],
              ),
            ),
            Divider(
              thickness: 1.0,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.itemCount,
                itemBuilder: widget.itemBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
