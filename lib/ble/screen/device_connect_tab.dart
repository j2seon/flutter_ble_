import 'package:ble_test3/ble/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../provider/flutter_ble.dart';

class DeviceConnectPage extends StatelessWidget {
  const DeviceConnectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FlutterBle _provider = context.watch<FlutterBle>();
    final DiscoveredDevice? dis = _provider.currentDevice;
    final DeviceModel device = DeviceModel(
      deviceId: dis?.id ?? "",
      serviceUuids: dis?.serviceUuids ?? [],
      name: dis?.name ?? '',
      connectionStatus: _provider.state,
    );
    return DeviceConnectView(
      data: _provider.recevice,
      deviceModel: device,
      isConnect: _provider.isConnect,
      connect: _provider.connect,
      sendData: _provider.writeCharacterisiticWithoutResponse,
      sendWithResp: _provider.writeCharacterisiticWithResponse,
    );
  }
}

class DeviceConnectView extends StatefulWidget {
  final DeviceModel deviceModel;
  final bool isConnect;
  final Future<void> Function({String? id}) connect;
  final void Function(String) sendData;
  final void Function(String) sendWithResp;
  final List<String> data;

  const DeviceConnectView(
      {required this.deviceModel,
      required this.connect,
      required this.isConnect,
      required this.data,
      required this.sendData,
      required this.sendWithResp,
      Key? key})
      : super(key: key);

  @override
  State<DeviceConnectView> createState() => _DeviceConnectViewState();
}

class _DeviceConnectViewState extends State<DeviceConnectView> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.indigo),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ID: ${widget.deviceModel.deviceId}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Status: ${widget.deviceModel.connectionStatus}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: widget.isConnect ? null : () async=> {
                          widget.connect(id: widget.deviceModel.deviceId)
                        },
                        child: const Text('connect'),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      TextButton(
                        style: const ButtonStyle(),
                        onPressed: () async {
                          widget.sendData(controller.text);
                          this.controller.clear();
                          focusNode.unfocus();
                        },
                        child: const Text('write'),
                      ),
                      TextButton(
                        onPressed: () async {
                          widget.sendWithResp(controller.text);
                          this.controller.clear();
                          focusNode.unfocus();
                        },
                        child: const Text('resp'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.indigo),
                    ),
                    child: ListView.builder(
                      itemCount: widget.data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('${widget.data[index]}'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
