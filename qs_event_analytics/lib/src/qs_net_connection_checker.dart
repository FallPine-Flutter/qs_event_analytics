part of '../qs_event_analytics.dart';

class _QsNetConnectionChecker {
  /// Func
  // 其他一些初始化操作
  Future<StreamSubscription<List<ConnectivityResult>>> _initialize() async {
    /// 初始化监听网络
    await _initConnectivity();
    return _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("检查网络状态失败 + $e");
      }
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.mobile)) {
      isConnected = true;
      QsEventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": true},
        ),
      );
    } else if (result.contains(ConnectivityResult.wifi)) {
      isConnected = true;
      QsEventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": true},
        ),
      );
    } else if (result.contains(ConnectivityResult.ethernet)) {
      isConnected = true;
      QsEventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": true},
        ),
      );
    } else if (result.contains(ConnectivityResult.vpn)) {
      isConnected = true;
      QsEventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": true},
        ),
      );
    } else if (result.contains(ConnectivityResult.bluetooth)) {
      isConnected = false;
      QsEventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": false},
        ),
      );
    } else if (result.contains(ConnectivityResult.other)) {
      isConnected = false;
      QsEventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": false},
        ),
      );
    } else if (result.contains(ConnectivityResult.none)) {
      isConnected = false;
      QsEventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": false},
        ),
      );
    } else {
      isConnected = false;
      QsEventBusTool.sendEvent(
        event: ScriptEventType(
          "net_connect_state",
          argument: {"isConnected": false},
        ),
      );
    }
  }

  /// Property
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool isConnected = false;

  /// 单例
  static final _QsNetConnectionChecker _instance =
      _QsNetConnectionChecker._internal();
  _QsNetConnectionChecker._internal();

  static Future<_QsNetConnectionChecker> getInstance() async {
    _instance._connectivitySubscription ??= await _instance._initialize();
    return _instance;
  }
}
