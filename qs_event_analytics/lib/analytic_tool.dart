import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ip_location/ip_location.dart';
import 'package:net_dio_request/net_request.dart';
import 'package:qs_event_analytics/analytic_api_parameter_name_model.dart';
import 'package:qs_event_analytics/analytic_error_db.dart';
import 'package:qs_event_analytics/analytic_error_model.dart';
import 'package:qs_event_analytics/analytic_model.dart';
import 'package:qs_event_analytics/event_bus_tool.dart';
import 'package:qs_event_analytics/firebase_analytic_tool.dart';
import 'package:qs_event_analytics/net_connection_checker.dart';
import 'package:uuid/uuid.dart';

class AnalyticTool {
  /// Func
  /// 初始化
  Future<void> initialize({
    required String userid,
    required String api,
    required AnalyticApiParameterNameModel apiParameterNameModel,
    required String systemVersion,
    required String appVersion,
    required List<String> ignoreFailedEventCodes,
    FirebaseOptions? options,
  }) async {
    _userid = userid;
    _api = api;
    _apiParameterNameModel = apiParameterNameModel;
    _systemVersion = systemVersion;
    _appVersion = appVersion;
    _ignoreFailedEventCodes = ignoreFailedEventCodes;

    Future.delayed(Duration(milliseconds: 100), () async {
      _netChecker = await NetConnectionChecker.getInstance();
    });

    await FirebaseAnalyticTool.initialize(options: options);
  }

  /// 打点
  void addEvent({
    required String code,
    required String name,
    required EventType type,
    int? timestamp,
    required String? belongPage,
    Map<String, String>? extra,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    var newTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    if (type == EventType.pageIn) {
      // 退出上一个页面
      if (currentPageCode.isNotEmpty) {
        addEvent(
          code: currentPageCode,
          name: _currentPageName,
          type: EventType.pageOut,
          timestamp: newTimestamp - 1,
          belongPage: currentPageCode,
          onSuccess: () {},
          onError: () {},
        );
      }
      // 记录新页面
      currentPageCode = code;
      _currentPageName = name;
      _currentPageExtra = extra;
    }

    // Firebase打点
    FirebaseAnalyticTool.addEvent(name: "${code}_${type.firebaseTypeCode}");

    // 接口记录
    recordEvent(
      sessionId: _sessionId,
      eventCode: code,
      eventName: type.eventNamePrefix.replaceAll("@name", name),
      eventType: type,
      timestamp: newTimestamp,
      belongPage: belongPage,
      extra: extra,
      onSuccess: onSuccess,
      onError: () {
        onError();
        // 记录失败的事件
        if (!_ignoreFailedEventCodes.contains(code)) {
          var model = AnalyticModel(
            sessionId: _sessionId,
            eventCode: code,
            eventName: name,
            eventType: type,
            timestamp: newTimestamp,
            belongPage: belongPage,
            extra: extra,
          );
          var data = jsonEncode(model);
          var errorModel = AnalyticErrorModel(data: data);
          AnalyticErrorDb.getInstance().then(
            (db) => db.insert(row: errorModel),
          );
        }
      },
    );
  }

  /// 记录打点事件
  Future<void> recordEvent({
    required String sessionId,
    required String eventCode,
    required String eventName,
    required EventType eventType,
    required int timestamp,
    String? belongPage,
    Map<String, dynamic>? extra,
    required Function() onSuccess,
    required Function() onError,
  }) async {
    if (_api.isEmpty) {
      return;
    }

    // 获取位置信息
    final loaction = await IpLocation.getIpLocation();
    // 将 extra 转为 JSON 字符串
    final extraContent = extra == null ? null : jsonEncode(extra);
    // 是否测试环境
    bool isTest = !kReleaseMode;

    if (_apiParameterNameModel == null) {
      return;
    }

    var parameters = {
      _apiParameterNameModel!.sessionId: sessionId,
      _apiParameterNameModel!.uuid: _userid,
      _apiParameterNameModel!.eventCode: eventCode,
      _apiParameterNameModel!.eventName: eventName,
      _apiParameterNameModel!.eventType: eventType.typeCode,
      _apiParameterNameModel!.eventTime: timestamp,
      _apiParameterNameModel!.userIp: loaction?.ip ?? "",
      _apiParameterNameModel!.countryCode: loaction?.country ?? "",
      _apiParameterNameModel!.cityCode: loaction?.city ?? "",
      _apiParameterNameModel!.systemVersion: _systemVersion,
      _apiParameterNameModel!.appVersion: _appVersion,
      _apiParameterNameModel!.attrPage: belongPage ?? "",
      _apiParameterNameModel!.eventContent: extraContent,
      _apiParameterNameModel!.env: isTest ? "dev" : "prd",
    };
    try {
      var response = await NetRequest.shared.postJson(
        _api,
        parameters: parameters,
        isShowLoading: false,
      );
      if (response?["code"] != 0) {
        onError();
      } else {
        onSuccess();
        if (kDebugMode) {
          print(
            "打点成功: $eventName, eventCode: $eventCode, belongPage: $belongPage, extra: $extra, type: $eventType",
          );
        }
      }
    } catch (e) {
      onError();
      return;
    }
  }

  /// 获取当前页面信息
  Map<String, dynamic> getCurrentPageData() {
    return {
      "code": currentPageCode,
      "name": _currentPageName,
      "extra": _currentPageExtra,
    };
  }

  /// 返回当前页面
  void returnToCurrentPage({required Map<String, dynamic> pageData}) {
    String? code = pageData["code"];
    String? name = pageData["name"];
    Map<String, String>? extra = pageData["extra"] as Map<String, String>?;

    if (code != null && name != null) {
      addEvent(
        code: code,
        name: name,
        type: EventType.pageIn,
        belongPage: code,
        extra: extra,
        onSuccess: () {},
        onError: () {},
      );
    }
  }

  /// 用户操作行为
  void _userAction() {
    EventBusTool.listenEvent(
      event: ScriptEventType("net_connect_state"),
      onEvent: (parameters) {
        final isConnected = parameters?["isConnected"] as bool?;
        if (isConnected == true) {
          // 重新发送失败事件
          _resendFailedEvents();
        }
      },
    );
    // 检查网络连接
    if (_netChecker?.isConnected == true) {
      // 重新发送失败事件
      _resendFailedEvents();
    }
  }

  /// 重新发送失败事件
  /// 从数据库中读取失败事件并重新发送
  Future<void> _resendFailedEvents() async {
    var db = await AnalyticErrorDb.getInstance();
    var rows = await db.queryAll();
    for (var row in rows) {
      try {
        var errorModel = AnalyticErrorModel(id: row.id, data: row.data);
        var model = AnalyticModel.fromJson(jsonDecode(errorModel.data ?? ""));

        if (model.eventCode == null || model.eventName == null) {
          // 删除事件
          db.delete(row: errorModel);
          continue;
        }

        recordEvent(
          sessionId: model.sessionId ?? "",
          eventCode: model.eventCode ?? "",
          eventName: model.eventName ?? "",
          eventType: model.eventType ?? EventType.state,
          timestamp: model.timestamp ?? DateTime.now().millisecondsSinceEpoch,
          belongPage: model.belongPage ?? "",
          extra: model.extra,
          onSuccess: () {
            // 删除成功的事件
            db.delete(row: errorModel);
          },
          onError: () {},
        );
      } catch (e) {
        if (kDebugMode) {
          print("重新发送失败事件失败: $e");
        }
      }
    }
  }

  /// 更新回话ID
  void updateSessionId() {
    _sessionId = Uuid().v4();
  }

  /// 获取当前回话ID
  String get sessionId => _sessionId;

  /// Property
  String _userid = "";
  String _api = "";
  AnalyticApiParameterNameModel? _apiParameterNameModel;
  String _systemVersion = "";
  String _appVersion = "";
  String _sessionId = const Uuid().v4();

  String currentPageCode = "";
  String _currentPageName = "";
  Map<String, dynamic>? _currentPageExtra;

  List<String> _ignoreFailedEventCodes = [];
  NetConnectionChecker? _netChecker;

  /// 单例
  static final AnalyticTool _instance = AnalyticTool._internal();
  AnalyticTool._internal() {
    _userAction();
  }

  static AnalyticTool getInstance() {
    return _instance;
  }
}
