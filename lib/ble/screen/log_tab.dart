import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../model/model.dart';
import '../provider/flutter_ble.dart';

class DeviceLogPage extends StatelessWidget {
  const DeviceLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterBle _provider = context.watch<FlutterBle>();
    return DeviceLogView(
      itemCount: _provider.logMessage?.length ?? 0,
      itemBuilder: (context, index) =>
          DeviceLogTextView(log: _provider.logMessage?[index] ?? '로그기록이 없습니다.'),
    );
  }
}




class DeviceLogView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  const DeviceLogView({required this.itemBuilder, required this.itemCount, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class DeviceLogTextView extends StatelessWidget {
  final String log;
  const DeviceLogTextView({required this.log,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(log);
  }
}

