import 'package:flutter_test/flutter_test.dart';
import 'package:qs_event_analytics/qs_api_config.dart';
import 'package:qs_event_analytics/qs_api_parameter_name_model.dart';

void main() {
  test('preserves all API parameter names through QsApiConfig', () {
    final parameterNameModel = QsApiParameterNameModel(
      sessionId: 'session_id',
      uuid: 'uuid',
      eventCode: 'event_code',
      eventName: 'event_name',
      eventType: 'event_type',
      eventTime: 'event_time',
      userIp: 'user_ip',
      countryCode: 'country_code',
      cityCode: 'city_code',
      systemVersion: 'system_version',
      appVersion: 'app_version',
      attrPage: 'attr_page',
      eventContent: 'event_content',
      env: 'env',
    );
    final config = QsApiConfig(
      userId: 'user_001',
      api: 'https://example.com/events',
      parameterNameModel: parameterNameModel,
      systemVersion: 'iOS 17.0',
      appVersion: '1.0.0',
      ignoreFailedEventCodes: const [],
    );

    expect(config.parameterNameModel, same(parameterNameModel));
    expect(parameterNameModel.sessionId, 'session_id');
    expect(parameterNameModel.uuid, 'uuid');
    expect(parameterNameModel.eventCode, 'event_code');
    expect(parameterNameModel.eventName, 'event_name');
    expect(parameterNameModel.eventType, 'event_type');
    expect(parameterNameModel.eventTime, 'event_time');
    expect(parameterNameModel.userIp, 'user_ip');
    expect(parameterNameModel.countryCode, 'country_code');
    expect(parameterNameModel.cityCode, 'city_code');
    expect(parameterNameModel.systemVersion, 'system_version');
    expect(parameterNameModel.appVersion, 'app_version');
    expect(parameterNameModel.attrPage, 'attr_page');
    expect(parameterNameModel.eventContent, 'event_content');
    expect(parameterNameModel.env, 'env');
  });
}
