part of '../qs_event_analytics.dart';

class _QsApiEventModel {
  _QsApiEventModel({
    required this.sessionId,
    required this.eventCode,
    required this.eventName,
    required this.eventType,
    required this.eventTime,
    required this.belongPage,
    required this.extra,
  });

  _QsApiEventModel.fromJson(Map<String, dynamic> json) {
    sessionId = json['session_id'];
    eventCode = json['event_code'];
    eventName = json['event_name'];
    try {
      eventType = QsApiEventType.values.firstWhere(
        (element) => element.name == json['event_type'],
      );
    } catch (_) {
      eventType = null;
    }

    eventTime = json['event_time'];
    belongPage = json['belong_page'];
    try {
      final jsonExtra = jsonDecode(json['extra']);
      if (jsonExtra is Map) {
        extra = Map<String, String>.from(jsonExtra);
      } else {
        extra = null;
      }
    } catch (_) {
      extra = null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'event_code': eventCode,
      'event_name': eventName,
      'event_type': eventType?.name,
      'event_time': eventTime,
      'belong_page': belongPage,
      'extra': jsonEncode(extra),
    };
  }

  String? sessionId;
  String? eventCode;
  String? eventName;
  QsApiEventType? eventType;
  int? eventTime;
  String? belongPage;
  Map<String, String>? extra;
}
