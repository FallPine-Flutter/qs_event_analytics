class AnalyticErrorModel {
  int? id;
  String? data;

  AnalyticErrorModel({this.id, this.data});

  AnalyticErrorModel.fromJson(Map<String, dynamic> json) {
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['id'] = id;
    json['data'] = data;

    return json;
  }

  /// 数据库表字段
  static Map<String, String> dbColumns() {
    return {"id": "INTEGER PRIMARY KEY", "data": "TEXT"};
  }
}
