part of '../qs_event_analytics.dart';

class _QsApiFailedEventModel {
  _QsApiFailedEventModel({this.eventId, this.eventData});

  _QsApiFailedEventModel.fromJson(Map<String, dynamic> json) {
    eventId = json['event_id'];
    eventData = json['event_data'];
  }

  Map<String, dynamic> toJson() {
    return {'event_id': eventId, 'event_data': eventData};
  }

  static Map<String, String> dbColumns() {
    return {"event_id": "INTEGER PRIMARY KEY", "event_data": "TEXT"};
  }

  int? eventId;
  String? eventData;
}
