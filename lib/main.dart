import 'package:ble_test3/ble/provider/flutter_ble.dart';
import 'package:ble_test3/ble/screen/device_detail_page.dart';
import 'package:ble_test3/ble/screen/device_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ble/screen/device_interaction_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FlutterBle>(
          create: (context) => FlutterBle(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (RouteSettings routeSettings) {
          if (routeSettings.name == DeviceDetailPage.path) {
            return MaterialPageRoute(
              settings: RouteSettings(name: DeviceDetailPage.path),
              builder: (_) => DeviceDetailPage(),
            );
          }
          if (routeSettings.name == DeviceInteractionPage.path) {
            return MaterialPageRoute(
              settings: RouteSettings(name: DeviceInteractionPage.path),
              builder: (_) => DeviceInteractionPage(),
            );
          }
          return MaterialPageRoute(
            settings: const RouteSettings(name: BleListPage.path),
            builder: (_) => BleListPage(),
          );
        },
      ),
    );
  }
}
