import 'package:flutter_test/flutter_test.dart';
import 'package:qs_event_analytics/analytic_error_model.dart';

void main() {
  group('AnalyticErrorModel', () {
    test('preserves the database row id and data', () {
      final model = AnalyticErrorModel.fromJson({
        'id': 42,
        'data': '{"eventCode":"click_save"}',
      });

      expect(model.id, 42);
      expect(model.data, '{"eventCode":"click_save"}');
    });

    test('preserves all fields through a JSON round trip', () {
      final row = <String, dynamic>{
        'id': 7,
        'data': '{"eventCode":"page_in"}',
      };

      expect(AnalyticErrorModel.fromJson(row).toJson(), row);
    });

    test('keeps id null when it is absent', () {
      final model = AnalyticErrorModel.fromJson({
        'data': '{"eventCode":"click_save"}',
      });

      expect(model.id, isNull);
      expect(model.data, '{"eventCode":"click_save"}');
    });
  });
}
