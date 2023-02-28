import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/flutter_ble.dart';


class DeviceInteractionPage extends StatelessWidget {
  static const path = '/device/interaction';
  const DeviceInteractionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterBle _provider = context.watch<FlutterBle>();
    return DeviceInteractionView();
  }
}

class DeviceInteractionView extends StatelessWidget {
  const DeviceInteractionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


