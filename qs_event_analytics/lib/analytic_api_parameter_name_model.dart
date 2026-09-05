class AnalyticApiParameterNameModel {
  AnalyticApiParameterNameModel({
    required this.sessionId,
    required this.uuid,
    required this.eventCode,
    required this.eventName,
    required this.eventType,
    required this.eventTime,
    required this.userIp,
    required this.countryCode,
    required this.cityCode,
    required this.systemVersion,
    required this.appVersion,
    required this.attrPage,
    required this.eventContent,
    required this.env,
  });

  // 会话ID
  final String sessionId;
  // 用户ID
  final String uuid;
  // 事件编码
  final String eventCode;
  // 事件名称
  final String eventName;
  //  事件类型
  final String eventType;
  // 事件时间
  final String eventTime;
  // 用户IP
  final String userIp;
  // 国家代码
  final String countryCode;
  // 城市代码
  final String cityCode;
  // 系统版本
  final String systemVersion;
  // 应用版本
  final String appVersion;
  // 所属页面
  final String attrPage;
  // 事件内容（额外参数）
  final String eventContent;
  // 环境
  final String env;
}
