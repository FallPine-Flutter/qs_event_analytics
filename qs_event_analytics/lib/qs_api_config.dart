import 'package:qs_event_analytics/qs_api_parameter_name_model.dart';

class QsApiConfig {
  const QsApiConfig({
    required this.userId,
    required this.api,
    required this.parameterNameModel,
    required this.systemVersion,
    required this.appVersion,
    required this.ignoreFailedEventCodes,
  });

  final String userId;
  final String api;
  final QsApiParameterNameModel parameterNameModel;
  final String systemVersion;
  final String appVersion;
  final List<String> ignoreFailedEventCodes;
}
