// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
// import 'package:ble_test3/widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// void main() {
//   runApp(const FlutterBlueApp());
// }
//
// class FlutterBlueApp extends StatelessWidget {
//   const FlutterBlueApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       color: Colors.lightBlue,
//       home: StreamBuilder<BluetoothState>(
//           stream: FlutterBluePlus.instance.state,
//           initialData: BluetoothState.unknown,
//           builder: (c, snapshot) {
//             final state = snapshot.data;
//             if (state == BluetoothState.on) {
//               return const FindDevicesScreen();
//             }
//             return BluetoothOffScreen(state: state);
//           }),
//     );
//   }
// }
//
// class BluetoothOffScreen extends StatelessWidget {
//   const BluetoothOffScreen({Key? key, this.state}) : super(key: key);
//
//   final BluetoothState? state;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.lightBlue,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             const Icon(
//               Icons.bluetooth_disabled,
//               size: 200.0,
//               color: Colors.white54,
//             ),
//             Text(
//               'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
//               style: Theme.of(context)
//                   .primaryTextTheme
//                   .subtitle2
//                   ?.copyWith(color: Colors.white),
//             ),
//             ElevatedButton(
//               child: const Text('TURN ON'),
//               onPressed: Platform.isAndroid
//                   ? () => FlutterBluePlus.instance.turnOn()
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FindDevicesScreen extends StatelessWidget {
//   const FindDevicesScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Find Devices'),
//         actions: [
//           ElevatedButton(
//             child: const Text('TURN OFF'),
//             style: ElevatedButton.styleFrom(
//               primary: Colors.black,
//               onPrimary: Colors.white,
//             ),
//             onPressed: Platform.isAndroid
//                 ? () => FlutterBluePlus.instance.turnOff()
//                 : null,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () => FlutterBluePlus.instance
//             .startScan(timeout: const Duration(seconds: 4)),
//         child: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               StreamBuilder<List<BluetoothDevice>>(
//                 stream: Stream.periodic(const Duration(seconds: 3))
//                     .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
//                 initialData: const [],
//                 builder: (c, snapshot) => Column(
//                   children: snapshot.data!
//                       .map((d) => ListTile(
//                     title: Text(d.name),
//                     subtitle: Text(d.id.toString()),
//                     trailing: StreamBuilder<BluetoothDeviceState>(
//                       stream: d.state,
//                       initialData: BluetoothDeviceState.disconnected,
//                       builder: (c, snapshot) {
//                         if (snapshot.data ==
//                             BluetoothDeviceState.connected) {
//                           return ElevatedButton(
//                             child: const Text('OPEN'),
//                             onPressed: () => Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         DeviceScreen(device: d))),
//                           );
//                         }
//                         return Text(snapshot.data.toString());
//                       },
//                     ),
//                   ))
//                       .toList(),
//                 ),
//               ),
//               StreamBuilder<List<ScanResult>>(
//                 stream: FlutterBluePlus.instance.scanResults,
//                 initialData: [],
//                 builder: (c, snapshot) {
//                   print("sssss: ${snapshot.data}");
//                   return Column(
//                     children: snapshot.data!
//                         .map(
//                           (r) => ScanResultTile(
//                         result: r,
//                         onTap: () async {
//                           print('r device${r.device}');
//                           await r.device.connect(timeout: Duration(seconds: 10)).timeout(
//                             Duration(seconds: 10),
//                             onTimeout: () => showDialog(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 title: Text('타임 아웃'),
//                               ),
//                             ),
//                           );
//                           //
//                           await r.device.discoverServices();
//                           Navigator.of(context)
//                               .push(MaterialPageRoute(builder: (context) {
//                             return DeviceScreen(device: r.device);
//                           }));
//
//                         },
//                       ),
//                     )
//                         .toList(),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: StreamBuilder<bool>(
//         stream: FlutterBluePlus.instance.isScanning,
//         initialData: false,
//         builder: (c, snapshot) {
//           if (snapshot.data!) {
//             return FloatingActionButton(
//               child: const Icon(Icons.stop),
//               onPressed: () => FlutterBluePlus.instance.stopScan(),
//               backgroundColor: Colors.red,
//             );
//           } else {
//             return FloatingActionButton(
//                 child: const Icon(Icons.search),
//                 onPressed: () => FlutterBluePlus.instance
//                     .startScan(timeout: const Duration(seconds: 4)));
//           }
//         },
//       ),
//     );
//   }
// }
//
// class DeviceScreen extends StatefulWidget {
//   const DeviceScreen({Key? key, required this.device}) : super(key: key);
//
//   final BluetoothDevice device;
//
//   @override
//   State<DeviceScreen> createState() => _DeviceScreenState();
// }
//
// class _DeviceScreenState extends State<DeviceScreen> {
//   List<int> _getRandomBytes() {
//     final math = Random();
//     return [
//       math.nextInt(255),
//       math.nextInt(255),
//       math.nextInt(255),
//       math.nextInt(255)
//     ];
//   }
//
//   List<Widget> _buildServiceTiles(List<BluetoothService> services) {
//     return services
//         .map(
//           (service) => ServiceTile(
//         service: service,
//         characteristicTiles: service.characteristics
//             .map(
//               (characteristic) => CharacteristicTile(
//             characteristic: characteristic,
//             onReadPressed: characteristic.read,
//             onWritePressed: () async {
//               await characteristic.write([], withoutResponse: true);
//               await characteristic.read();
//             },
//             onNotificationPressed: () async {
//               await characteristic
//                   .setNotifyValue(!characteristic.isNotifying);
//               await characteristic.read();
//             },
//             descriptorTiles: characteristic.descriptors
//                 .map(
//                   (descriptor) => DescriptorTile(
//                 descriptor: descriptor,
//                 onReadPressed: descriptor.read,
//                 onWritePressed: () =>
//                     descriptor.write(_getRandomBytes()),
//               ),
//             )
//                 .toList(),
//           ),
//         )
//             .toList(),
//       ),
//     )
//         .toList();
//   }
//
//   // checkConnectedDevices(BluetoothDevice device) async{
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.device.name),
//         actions: <Widget>[
//           StreamBuilder<BluetoothDeviceState>(
//             stream: widget.device.state,
//             initialData: BluetoothDeviceState.connecting,
//             builder: (c, snapshot) {
//               VoidCallback? onPressed;
//               String text;
//               switch (snapshot.data) {
//                 case BluetoothDeviceState.connected:
//                   onPressed = () => widget.device.disconnect();
//                   text = 'DISCONNECT';
//                   break;
//                 case BluetoothDeviceState.disconnected:
//                   onPressed = () => widget.device.connect();
//                   text = 'CONNECT';
//                   break;
//                 default:
//                   onPressed = null;
//                   text = snapshot.data.toString().substring(21).toUpperCase();
//                   break;
//               }
//               return TextButton(
//                   onPressed: onPressed,
//                   child: Text(
//                     text,
//                     style: Theme.of(context)
//                         .primaryTextTheme
//                         .button
//                         ?.copyWith(color: Colors.white),
//                   ));
//             },
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             StreamBuilder<BluetoothDeviceState>(
//               stream: widget.device.state,
//               initialData: BluetoothDeviceState.connecting,
//               builder: (c, snapshot) => ListTile(
//                 leading: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     snapshot.data == BluetoothDeviceState.connected
//                         ? const Icon(Icons.bluetooth_connected)
//                         : const Icon(Icons.bluetooth_disabled),
//                     snapshot.data == BluetoothDeviceState.connected
//                         ? StreamBuilder<int>(
//                         stream: rssiStream(),
//                         builder: (context, snapshot) {
//                           return Text(
//                               snapshot.hasData ? '${snapshot.data}dBm' : '',
//                               style: Theme.of(context).textTheme.caption);
//                         })
//                         : Text('', style: Theme.of(context).textTheme.caption),
//                   ],
//                 ),
//                 title: Text(
//                     'Device is ${snapshot.data.toString().split('.')[1]}.'),
//                 subtitle: Text('${widget.device.id}'),
//                 trailing: StreamBuilder<bool>(
//                   stream: widget.device.isDiscoveringServices,
//                   initialData: false,
//                   builder: (c, snapshot) => IndexedStack(
//                     index: snapshot.data! ? 1 : 0,
//                     children: <Widget>[
//                       IconButton(
//                         icon: const Icon(Icons.refresh),
//                         onPressed: () => widget.device.discoverServices(),
//                       ),
//                       const IconButton(
//                         icon: SizedBox(
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation(Colors.grey),
//                           ),
//                           width: 18.0,
//                           height: 18.0,
//                         ),
//                         onPressed: null,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             StreamBuilder<int>(
//               stream: widget.device.mtu,
//               initialData: 0,
//               builder: (c, snapshot) {
//                 return ListTile(
//                   title: const Text('MTU Size'),
//                   subtitle: Text('${snapshot.data} bytes'),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.edit),
//                     onPressed: () => widget.device.requestMtu(223),
//                   ),
//                 );
//               },
//             ),
//             StreamBuilder<List<BluetoothService>>(
//               stream: widget.device.services,
//               builder: (c, snapshot) {
//                 print('snapshot :${snapshot.data}');
//                 return Column(
//                   children: snapshot.data!
//                       .map(
//                         (service) => ServiceTile(
//                       service: service,
//                       characteristicTiles: service.characteristics
//                           .map(
//                             (characteristic) => CharacteristicTile(
//                           characteristic: characteristic,
//                           onReadPressed: characteristic.read,
//                           onWritePressed: () async {
//                             await characteristic
//                                 .write([], withoutResponse: true);
//                             await characteristic.read();
//                           },
//                           onNotificationPressed: () async {
//                             await characteristic.setNotifyValue(
//                                 !characteristic.isNotifying);
//                             await characteristic.read();
//                           },
//                           descriptorTiles: characteristic.descriptors
//                               .map(
//                                 (descriptor) => DescriptorTile(
//                               descriptor: descriptor,
//                               onReadPressed: descriptor.read,
//                               onWritePressed: () => descriptor
//                                   .write(_getRandomBytes()),
//                             ),
//                           )
//                               .toList(),
//                         ),
//                       )
//                           .toList(),
//                     ),
//                   )
//                       .toList(),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Stream<int> rssiStream() async* {
//     var isConnected = true;
//     final subscription = widget.device.state.listen((state) {
//       isConnected = state == BluetoothDeviceState.connected;
//     });
//     while (isConnected) {
//       yield await widget.device.readRssi();
//       await Future.delayed(const Duration(seconds: 1));
//     }
//     subscription.cancel();
//     // Device disconnected, stopping RSSI stream
//   }
// }
