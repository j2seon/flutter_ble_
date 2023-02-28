import 'package:flutter/material.dart';


// desc 블루투스 아이콘 UI
class BluetoothIcon extends StatelessWidget {
  const BluetoothIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 64,
    height: 64,
    child: Align(alignment: Alignment.center, child: Icon(Icons.bluetooth)),
  );
}