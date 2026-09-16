import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:qs_event_analytics/qs_api_config.dart';
import 'package:qs_event_analytics/qs_api_event_type.dart';
import 'package:qs_event_analytics/qs_event_bus_tool.dart';
import 'package:qs_event_analytics/qs_event_category.dart';
import 'package:qs_event_analytics/qs_firebase_analytic.dart';
import 'package:qs_event_analytics/qs_firebase_config.dart';
import 'package:qs_ip_location/qs_ip_location.dart';
import 'package:qs_net_request/qs_net_request.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

part 'src/qs_api_event_model.dart';
part 'src/qs_api_failed_event_db.dart';
part 'src/qs_api_failed_event_model.dart';
part 'src/qs_net_connection_checker.dart';

class QsEventAnalytics {
  /// System Funcs
  QsEventAnalytics._internal() {
    _listenConnectionChanges();
  }

  /// Custom Funcs
  Future<void> initialize({
    required QsEventCategory category,
    QsFirebaseConfig? firebaseConfig,
    QsApiConfig? apiConfig,
  }) async {
    _validateInitialization(
      category: category,
      firebaseConfig: firebaseConfig,
      apiConfig: apiConfig,
    );

    if (category.shouldRecordFirebase) {
      await QsFirebaseAnalytic.initialize(options: firebaseConfig!.options);
    }

    _category = category;
    _apiConfig = apiConfig;
    _isInitialized = true;

    if (category.shouldRecordApi) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        _netChecker = await _QsNetConnectionChecker.getInstance();
      });
    }
  }

  Future<void> addFirebaseEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    _ensureFirebaseEnabled();
    await QsFirebaseAnalytic.addEvent(name: name, parameters: parameters);
  }

  void addApiEvent({
    required String code,
    required String name,
    required QsApiEventType type,
    int? timestamp,
    required String? belongPage,
    Map<String, String>? extra,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) {
    _ensureApiEnabled();

    final newTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    if (type == QsApiEventType.pageIn) {
      if (currentPageCode.isNotEmpty) {
        addApiEvent(
          code: currentPageCode,
          name: _currentPageName,
          type: QsApiEventType.pageOut,
          timestamp: newTimestamp - 1,
          belongPage: currentPageCode,
          onSuccess: () {},
          onError: () {},
        );
      }
      currentPageCode = code;
      _currentPageName = name;
      _currentPageExtra = extra;
    }

    _recordEvent(
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
        final apiConfig = _apiConfig!;
        if (!apiConfig.ignoreFailedEventCodes.contains(code)) {
          final model = _QsApiEventModel(
            sessionId: _sessionId,
            eventCode: code,
            eventName: name,
            eventType: type,
            eventTime: newTimestamp,
            belongPage: belongPage,
            extra: extra,
          );
          final errorModel = _QsApiFailedEventModel(
            eventData: jsonEncode(model),
          );
          _QsApiFailedEventDb.getInstance().then(
            (db) => db.insert(row: errorModel),
          );
        }
      },
    );
  }

  Map<String, dynamic> getCurrentPageData() {
    return {
      "code": currentPageCode,
      "name": _currentPageName,
      "extra": _currentPageExtra,
    };
  }

  void returnToCurrentPage({required Map<String, dynamic> pageData}) {
    final code = pageData["code"] as String?;
    final name = pageData["name"] as String?;
    final extra = pageData["extra"] as Map<String, String>?;

    if (code != null && name != null) {
      addApiEvent(
        code: code,
        name: name,
        type: QsApiEventType.pageIn,
        belongPage: code,
        extra: extra,
        onSuccess: () {},
        onError: () {},
      );
    }
  }

  void updateSessionId() {
    _sessionId = const Uuid().v4();
  }

  String get sessionId => _sessionId;

  static QsEventAnalytics getInstance() {
    return _instance;
  }

  void _validateInitialization({
    required QsEventCategory category,
    required QsFirebaseConfig? firebaseConfig,
    required QsApiConfig? apiConfig,
  }) {
    switch (category) {
      case QsEventCategory.all:
        if (firebaseConfig == null || apiConfig == null) {
          throw ArgumentError(
            'QsEventCategory.all 必须同时提供 firebaseConfig 和 apiConfig。',
          );
        }
        return;
      case QsEventCategory.firebase:
        if (firebaseConfig == null || apiConfig != null) {
          throw ArgumentError('QsEventCategory.firebase 只能提供 firebaseConfig。');
        }
        return;
      case QsEventCategory.api:
        if (apiConfig == null || firebaseConfig != null) {
          throw ArgumentError('QsEventCategory.api 只能提供 apiConfig。');
        }
        return;
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('请先调用 QsEventAnalytics.initialize()。');
    }
  }

  void _ensureFirebaseEnabled() {
    _ensureInitialized();
    if (_category?.shouldRecordFirebase != true) {
      throw StateError('当前 QsEventCategory 未启用 Firebase 埋点。');
    }
  }

  void _ensureApiEnabled() {
    _ensureInitialized();
    if (_category?.shouldRecordApi != true) {
      throw StateError('当前 QsEventCategory 未启用 API 埋点。');
    }
  }

  Future<void> _recordEvent({
    required String sessionId,
    required String eventCode,
    required String eventName,
    required QsApiEventType eventType,
    required int timestamp,
    String? belongPage,
    Map<String, dynamic>? extra,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    final apiConfig = _apiConfig;
    if (apiConfig == null || apiConfig.api.isEmpty) {
      return;
    }

    final location = await QsIpLocation.getIpLocation();
    final extraContent = extra == null ? null : jsonEncode(extra);
    final isTest = !kReleaseMode;
    final parameterNames = apiConfig.parameterNameModel;
    final parameters = {
      parameterNames.sessionId: sessionId,
      parameterNames.uuid: apiConfig.userId,
      parameterNames.eventCode: eventCode,
      parameterNames.eventName: eventName,
      parameterNames.eventType: eventType.typeCode,
      parameterNames.eventTime: timestamp,
      parameterNames.userIp: location?.ip ?? "",
      parameterNames.countryCode: location?.countryName ?? "",
      parameterNames.cityCode: location?.cityName ?? "",
      parameterNames.systemVersion: apiConfig.systemVersion,
      parameterNames.appVersion: apiConfig.appVersion,
      parameterNames.attrPage: belongPage ?? "",
      parameterNames.eventContent: extraContent,
      parameterNames.env: isTest ? "dev" : "prd",
    };

    try {
      final response = await QsNetRequest.getInstance().postJson(
        apiConfig.api,
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
    } catch (_) {
      onError();
    }
  }

  void _listenConnectionChanges() {
    QsEventBusTool.listenEvent(
      event: ScriptEventType("net_connect_state"),
      onEvent: (parameters) {
        final isConnected = parameters?["isConnected"] as bool?;
        if (_category?.shouldRecordApi == true && isConnected == true) {
          _resendFailedEvents();
        }
      },
    );
    if (_category?.shouldRecordApi == true &&
        _netChecker?.isConnected == true) {
      _resendFailedEvents();
    }
  }

  Future<void> _resendFailedEvents() async {
    if (_category?.shouldRecordApi != true) {
      return;
    }

    final db = await _QsApiFailedEventDb.getInstance();
    final rows = await db.queryAll();
    for (final row in rows) {
      try {
        final errorModel = _QsApiFailedEventModel(
          eventId: row.eventId,
          eventData: row.eventData,
        );
        final model = _QsApiEventModel.fromJson(
          jsonDecode(errorModel.eventData ?? ""),
        );

        if (model.eventCode == null || model.eventName == null) {
          db.delete(row: errorModel);
          continue;
        }

        _recordEvent(
          sessionId: model.sessionId ?? "",
          eventCode: model.eventCode ?? "",
          eventName: model.eventName ?? "",
          eventType: model.eventType ?? QsApiEventType.state,
          timestamp: model.eventTime ?? DateTime.now().millisecondsSinceEpoch,
          belongPage: model.belongPage ?? "",
          extra: model.extra,
          onSuccess: () {
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

  /// Properties
  QsEventCategory? _category;
  QsApiConfig? _apiConfig;
  bool _isInitialized = false;
  String _sessionId = const Uuid().v4();

  String currentPageCode = "";
  String _currentPageName = "";
  Map<String, dynamic>? _currentPageExtra;

  _QsNetConnectionChecker? _netChecker;

  static final QsEventAnalytics _instance = QsEventAnalytics._internal();
}
