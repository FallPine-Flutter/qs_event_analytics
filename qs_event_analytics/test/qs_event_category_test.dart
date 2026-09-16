import 'package:flutter_test/flutter_test.dart';
import 'package:qs_event_analytics/qs_api_config.dart';
import 'package:qs_event_analytics/qs_api_event_type.dart';
import 'package:qs_event_analytics/qs_api_parameter_name_model.dart';
import 'package:qs_event_analytics/qs_event_analytics.dart';
import 'package:qs_event_analytics/qs_event_category.dart';
import 'package:qs_event_analytics/qs_firebase_config.dart';

void main() {
  group('QsEventCategory', () {
    test('exposes the enabled channels', () {
      expect(QsEventCategory.all.shouldRecordFirebase, isTrue);
      expect(QsEventCategory.all.shouldRecordApi, isTrue);
      expect(QsEventCategory.firebase.shouldRecordFirebase, isTrue);
      expect(QsEventCategory.firebase.shouldRecordApi, isFalse);
      expect(QsEventCategory.api.shouldRecordFirebase, isFalse);
      expect(QsEventCategory.api.shouldRecordApi, isTrue);
    });
  });

  group('QsEventAnalytics initialization contract', () {
    final analytics = QsEventAnalytics.getInstance();
    final apiConfig = _createApiConfig();
    const firebaseConfig = QsFirebaseConfig();

    test('rejects incomplete all configuration', () async {
      await expectLater(
        analytics.initialize(
          category: QsEventCategory.all,
          firebaseConfig: firebaseConfig,
        ),
        throwsArgumentError,
      );
    });

    test('rejects API configuration in firebase-only mode', () async {
      await expectLater(
        analytics.initialize(
          category: QsEventCategory.firebase,
          firebaseConfig: firebaseConfig,
          apiConfig: apiConfig,
        ),
        throwsArgumentError,
      );
    });

    test('rejects Firebase configuration in API-only mode', () async {
      await expectLater(
        analytics.initialize(
          category: QsEventCategory.api,
          firebaseConfig: firebaseConfig,
          apiConfig: apiConfig,
        ),
        throwsArgumentError,
      );
    });

    test('rejects event calls before initialization', () async {
      await expectLater(
        analytics.addFirebaseEvent(name: 'test_event'),
        throwsStateError,
      );
      expect(
        () => analytics.addApiEvent(
          code: 'test_event',
          name: '测试事件',
          type: QsApiEventType.click,
          belongPage: null,
          onSuccess: () {},
          onError: () {},
        ),
        throwsStateError,
      );
    });
  });
}

QsApiConfig _createApiConfig() {
  return QsApiConfig(
    userId: 'user_001',
    api: 'https://example.com/events',
    parameterNameModel: QsApiParameterNameModel(
      sessionId: 'sessionId',
      uuid: 'uuid',
      eventCode: 'eventCode',
      eventName: 'eventName',
      eventType: 'eventType',
      eventTime: 'eventTime',
      userIp: 'userIp',
      countryCode: 'countryCode',
      cityCode: 'cityCode',
      systemVersion: 'systemVersion',
      appVersion: 'appVersion',
      attrPage: 'attrPage',
      eventContent: 'eventContent',
      env: 'env',
    ),
    systemVersion: 'iOS 17.0',
    appVersion: '1.0.0',
    ignoreFailedEventCodes: const [],
  );
}
