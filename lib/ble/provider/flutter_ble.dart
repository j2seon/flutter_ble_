import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterBle with ChangeNotifier {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  final Uuid _myServiceUuid =
      Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb");
  final Uuid _myCharacteristicUuid =
      Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// state 1. 스캔된 디바이스 id, device
  final Map<String, DiscoveredDevice> _scanData = {};

  Map<String, DiscoveredDevice> get scanData => {..._scanData};

  /// state2. 스캔상태
  bool _isScan = false;

  bool get isScan => _isScan;

  /// state3. 스캔리슨
  StreamSubscription? scanSubscription;

  //desc 권한확인
  Future<void> _blePermission() async {
    setLogMessage('권한확인');
    this.notifyListeners();
    PermissionStatus advertise = await Permission.bluetoothAdvertise.request();
    PermissionStatus bluetoothScan = await Permission.bluetoothScan.request();
    PermissionStatus bluetoothConnect =
        await Permission.bluetoothConnect.request();
    PermissionStatus location = await Permission.location.request();
    if (advertise.isDenied ||
        bluetoothConnect.isDenied ||
        bluetoothScan.isDenied ||
        location.isDenied) {
      await _blePermission();
    }
  }

  Future<void> connectedSave(String deviceId) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(deviceId, deviceId);
  }

  Future<void> autoConnect(String deviceId) async{
    final prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString(deviceId);
    connect(id: deviceId);
  }


  //desc 스캔시작
  Future<void> startScan({List<Uuid>? withServices}) async {
    await _initPrefs();
    if (isScan) return;
    scanData.clear();
    await _blePermission();
    _isScan = true;
    setLogMessage('Scan Start');
    logClear();
    scanSubscription = flutterReactiveBle
        .scanForDevices(
            withServices: withServices ?? [], scanMode: ScanMode.lowLatency)
        .listen((device) {
      _scanData.addAll({device.id: device});
      if (scanData.length > 20) {
        scanStop();
        _isScan = false;
        scanData.clear();
      }
      this.notifyListeners();
    });
    notifyListeners();
  }

  //desc 스캔종료
  void scanStop() {
    scanSubscription?.cancel();
    _isScan = false;
    setLogMessage('Scan Stop');
    this.notifyListeners();
  }

  /// state4. logMessage
  final List<String> _logMessage = [];

  List<String>? get logMessage => _logMessage;

  //desc 로그세팅
  void setLogMessage(String message) {
    DateTime dateTime = DateTime.now();
    _logMessage.add('${dateTime} : $message');
    notifyListeners();
    print('log : $logMessage');
  }

  //desc 로그 삭제
  void logClear() {
    if (logMessage == null) return;
    if (logMessage!.length > 15) {
      //15개 넘어가면 앞에 로그부터 지우기
      _logMessage.removeRange(0, 14);
    }
    this.notifyListeners();
    print('log : $logMessage');
  }

  ///연결된적있는 디바이스 저장
  ///todo 연결된 적있는 디바이스 있을 때는 >> 바로 연결하기? shared_prefrerences 이용해보자
  final Map<String, DiscoveredDevice> _connectedDevices = {};

  Map<String, DiscoveredDevice> get connectedDevices => {..._connectedDevices};

  ///연결 여부 체크
  bool _isConnect = false;

  bool get isConnect => _isConnect;

  ///연결상태 듣는 litener사용
  StreamSubscription<ConnectionStateUpdate>? connectionSub;

  /// state 5. 선택된 디바이스 index번호
  int? connectIndex;

  //desc 연결 디바이스 index설정
  void setDeviceIndex(int index) {
    if (connectIndex == index) return;
    connectIndex = index;
    notifyListeners();
    // setDeviceId();
  }

  ///state 6. 연결 id
  String? _deviceId;

  String? get deviceId => _deviceId;

  //desc 연결 디바이스 getter
  DiscoveredDevice? get currentDevice {
    return this.scanData.values.toList()[connectIndex!];
    // return this.scanData[deviceId];
  }

  //desc 연결
  Future<void> connect({String? id}) async {
    if (isConnect) return; //연결 되어있는 상태면 리턴
    _isConnect = true; // 연결 true로 바꿔주고
    final current = this.scanData.values.toList()[connectIndex!]; // 현재 연결된 디바이스
    _deviceId = current.id; // id 지정해주고
    connectedSave(current.id);
    notifyListeners(); // 변경되었으니 알려주고
    connectionSub = flutterReactiveBle.connectToDevice(connectionTimeout: Duration(seconds: 5),
        id: deviceId!,
        servicesWithCharacteristicsToDiscover: {
          current.serviceUuids[0]: current.serviceUuids
        }).listen((update) async {
      _state = update.connectionState; //연결상태 업데이트해주고
      switch (update.connectionState) {
        case DeviceConnectionState.connected: //연결시에
          setLogMessage(' $deviceId : ${update.connectionState}');
          _isConnect = true;
          await discoverServices(deviceId: update.deviceId);
          QualifiedCharacteristic characteristic= QualifiedCharacteristic(
              characteristicId:
              discover[current.serviceUuids[0]]!.characteristicId,
              serviceId: current.serviceUuids[0],
              deviceId: update.deviceId);
          _writeCharacteristic = characteristic;
          receiveSub = flutterReactiveBle
              .subscribeToCharacteristic(characteristic)
              .listen((value) {
            final result = asciiDecoder.convert(value);
            final DateTime dateTime = DateTime.now()
              ..day
              ..hour
              ..minute
              ..millisecond;
            _recevice.add('$dateTime : $result');

            if (recevice.length > 14) {
              _recevice.removeRange(0, 14);
            }
            notifyListeners();
          });
          setLogMessage('Subscribing to: ${characteristic.characteristicId} ');
          break;

        case DeviceConnectionState.disconnected: //끊을때
          setLogMessage('$deviceId : ${update.connectionState}');
          _state = update.connectionState;
          await disconnect(id: update.deviceId);
          break;

        default: //ing
          setLogMessage('${update.deviceId} : ${update.connectionState}');
          _state = update.connectionState;
          break;
      }
      logClear();
      notifyListeners();
    }, onError: (Object e) async {
      //에러나는 경우 로그
      setLogMessage('Connecting to device $deviceId resulted in error $e');
      _isConnect = false; // 에러나면 연결안된거니까 false
      _deviceId = null; //지정될수도 있으니까 null로 바꿔주고
      await disconnect(id: deviceId);
      notifyListeners();
    });
  }

  //desc 연결 종료
  Future<void> disconnect({String? id}) async {
    await connectionSub?.cancel();
    _isConnect = false; // 연결상태 종료
    _deviceId = null; // 연결종료로 비워주기
    _discover.clear();
    _recevice.clear();
    _writeCharacteristic = null;
    receiveSub?.cancel();
    _state = DeviceConnectionState.disconnected; // 음 이건 없어도될거같긴한데..
    logClear();
    notifyListeners();
  }

  ///state 7. 연결상태....
  DeviceConnectionState _state = DeviceConnectionState.disconnected;
  DeviceConnectionState get state => _state;

  final Map<Uuid, DiscoveredCharacteristic> _discover = {};
  Map<Uuid, DiscoveredCharacteristic> get discover => _discover;

  QualifiedCharacteristic? _writeCharacteristic;
  QualifiedCharacteristic? get writeCharacteristic=> _writeCharacteristic;


  //desc 연결된 디바이스 서비스 가져오기
  Future<void> discoverServices({required String deviceId}) async {
    try {
      setLogMessage('Start discovering services for: $deviceId');
      await flutterReactiveBle
          .discoverServices(deviceId)
          .then((value) => value.forEach((e) {
                if (e.serviceId == currentDevice?.serviceUuids[0]) {
                  _discover.addAll({e.serviceId: e.characteristics[0]});
                }
                notifyListeners();
              }));
      setLogMessage('Discovering services finished');
    } on Exception catch (e) {
      setLogMessage('Error occured when discovering services: $e');
      rethrow;
    }
    logClear();
  }

  //읽기
  Future<List<int>> readCharacteristic(
      QualifiedCharacteristic characteristic) async {
    try {
      final result =
          await flutterReactiveBle.readCharacteristic(characteristic);
      setLogMessage('Read ${characteristic.characteristicId}: value = $result');
      return result;
    } on Exception catch (e, s) {
      setLogMessage(
        'Error occured when reading ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }


  //응답 있는 쓰기
  Future<void> writeCharacterisiticWithResponse(String? text) async {
    try {
      setLogMessage(
          'Write with response value : $text ');
      await flutterReactiveBle.writeCharacteristicWithResponse(writeCharacteristic!,
          value: text?.codeUnits ?? []);
    } on Exception catch (e, s) {
      setLogMessage(
        'Error occured when writing $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  /// state 9. 받은데이터 리스닝
  StreamSubscription<List<int>>? receiveSub;

  /// state 10. 받는 데이터
  final List<String> _recevice = [];

  List<String> get recevice => _recevice;

  ///변환
  final AsciiDecoder asciiDecoder = AsciiDecoder();

  ///
  Future<void> subScribeToCharacteristic(
      QualifiedCharacteristic characteristic) async {
    receiveSub = flutterReactiveBle
        .subscribeToCharacteristic(characteristic)
        .listen((value) {
      final result = asciiDecoder.convert(value);
      final DateTime dateTime = DateTime.now()
        ..day
        ..hour
        ..minute
        ..millisecond;
      _recevice.add('$dateTime : $result');
      print(_recevice);

      if (recevice.length > 14) {
        _recevice.removeRange(0, 14);
      }
      notifyListeners();
    });
    setLogMessage('Subscribing to: ${characteristic.characteristicId} ');
    notifyListeners();
  }


  //응답 없는 쓰기
  Future<void> writeCharacterisiticWithoutResponse(String? text) async {
    try {
      await flutterReactiveBle
          .writeCharacteristicWithoutResponse(_writeCharacteristic!, value: text?.codeUnits ?? []);
      setLogMessage(
          'Write without response value: $text to ${_writeCharacteristic?.characteristicId}');
    } on Exception catch (e, s) {
      setLogMessage(
        'Error occured when writing ${_writeCharacteristic?.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }
}
