import 'package:flutter_test/flutter_test.dart';
import 'package:qs_event_analytics/qs_api_event_type.dart';

void main() {
  test('preserves API type codes', () {
    expect(QsApiEventType.appIn.typeCode, 'in');
    expect(QsApiEventType.appOut.typeCode, 'out');
    expect(QsApiEventType.pageIn.typeCode, 'in');
    expect(QsApiEventType.pageOut.typeCode, 'out');
    expect(QsApiEventType.click.typeCode, 'click');
    expect(QsApiEventType.valueChange.typeCode, 'click');
    expect(QsApiEventType.load.typeCode, 'load');
    expect(QsApiEventType.show.typeCode, 'in');
    expect(QsApiEventType.close.typeCode, 'out');
    expect(QsApiEventType.state.typeCode, 'load');
    expect(QsApiEventType.error.typeCode, 'error');
  });

  test('preserves API event name prefixes', () {
    expect(QsApiEventType.appIn.eventNamePrefix, '@name');
    expect(QsApiEventType.appOut.eventNamePrefix, '@name');
    expect(QsApiEventType.pageIn.eventNamePrefix, '进入-【@name】');
    expect(QsApiEventType.pageOut.eventNamePrefix, '离开-【@name】');
    expect(QsApiEventType.click.eventNamePrefix, '点击-@name');
    expect(QsApiEventType.valueChange.eventNamePrefix, '值改变-@name');
    expect(QsApiEventType.load.eventNamePrefix, '加载-@name');
    expect(QsApiEventType.show.eventNamePrefix, '显示-【@name】');
    expect(QsApiEventType.close.eventNamePrefix, '关闭-【@name】');
    expect(QsApiEventType.state.eventNamePrefix, '状态-@name');
    expect(QsApiEventType.error.eventNamePrefix, '错误-@name');
  });
}
