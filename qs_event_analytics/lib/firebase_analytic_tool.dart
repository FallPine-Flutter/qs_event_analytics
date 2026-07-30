import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseAnalyticTool {
  /// Func
  // 初始化
  static Future<void> initialize({FirebaseOptions? options}) async {
    await Firebase.initializeApp(options: options);
  }

  /// 打点
  static Future<void> addEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    // 断言：事件名长度不能超过40
    assert(name.length <= 40, '事件名长度不能超过40个字符');

    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Property
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
}
