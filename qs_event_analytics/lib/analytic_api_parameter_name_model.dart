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

  final String sessionId;
  final String uuid;
  final String eventCode;
  final String eventName;
  final String eventType;
  final String eventTime;
  final String userIp;
  final String countryCode;
  final String cityCode;
  final String systemVersion;
  final String appVersion;
  final String attrPage;
  final String eventContent;
  final String env;
}