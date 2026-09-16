# qs_event_analytics

`qs_event_analytics` 是一个 Flutter 埋点插件，支持分别使用 Firebase Analytics、业务 API，或同时启用两个通道。

## 安装

```yaml
dependencies:
  qs_event_analytics: ^1.1.5
```

本地调试：

```yaml
dependencies:
  qs_event_analytics:
    path: ../qs_event_analytics
```

## 通道类型

| 类型 | Firebase | 业务 API |
| --- | --- | --- |
| `QsEventCategory.firebase` | 启用 | 禁用 |
| `QsEventCategory.api` | 禁用 | 启用 |
| `QsEventCategory.all` | 启用 | 启用 |

初始化配置必须与通道类型严格匹配。缺少必要配置或向单通道传入另一通道的配置时，`initialize()` 会抛出 `ArgumentError`。

## 导入

```dart
import 'package:qs_event_analytics/qs_api_config.dart';
import 'package:qs_event_analytics/qs_api_event_type.dart';
import 'package:qs_event_analytics/qs_api_parameter_name_model.dart';
import 'package:qs_event_analytics/qs_event_analytics.dart';
import 'package:qs_event_analytics/qs_event_category.dart';
import 'package:qs_event_analytics/qs_firebase_config.dart';
```

## 初始化

### 仅 Firebase

业务项目需要先按 Firebase 官方要求配置 Android 和 iOS 工程。

```dart
await QsEventAnalytics.getInstance().initialize(
  category: QsEventCategory.firebase,
  firebaseConfig: const QsFirebaseConfig(),
);
```

如需显式传入 Firebase 配置：

```dart
await QsEventAnalytics.getInstance().initialize(
  category: QsEventCategory.firebase,
  firebaseConfig: QsFirebaseConfig(options: firebaseOptions),
);
```

### 仅业务 API

```dart
final apiConfig = QsApiConfig(
  userId: 'user_001',
  api: 'https://example.com/api/event/report',
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

await QsEventAnalytics.getInstance().initialize(
  category: QsEventCategory.api,
  apiConfig: apiConfig,
);
```

`parameterNameModel` 中的值是业务接口实际使用的 JSON 键名。

插件通过 `POST JSON` 请求 `api`。各字段的数据来源如下：

| 映射属性 | 请求值 |
| --- | --- |
| `sessionId` | 当前会话 ID |
| `uuid` | `userId` |
| `eventCode` | 事件编码 |
| `eventName` | 根据事件类型生成的事件名称 |
| `eventType` | 事件类型编码 |
| `eventTime` | 事件毫秒时间戳 |
| `userIp` | 当前 IP 地址，获取失败时为空字符串 |
| `countryCode` | 国家或地区名称，获取失败时为空字符串 |
| `cityCode` | 城市名称，获取失败时为空字符串 |
| `systemVersion` | `systemVersion` |
| `appVersion` | `appVersion` |
| `attrPage` | 所属页面，为 `null` 时发送空字符串 |
| `eventContent` | `extra` 序列化后的 JSON 字符串，未传时值为 `null` |
| `env` | Debug/Profile 为 `dev`，Release 为 `prd` |

响应 JSON 的 `code` 为数字 `0` 时调用 `onSuccess`，其他响应或请求异常调用 `onError`。

### 同时启用

```dart
await QsEventAnalytics.getInstance().initialize(
  category: QsEventCategory.all,
  firebaseConfig: const QsFirebaseConfig(),
  apiConfig: apiConfig,
);
```

`all` 只表示两个通道均可用，不会自动把一次调用复制到另一个通道。调用方需要分别调用两个上报方法。

## Firebase 上报

```dart
await QsEventAnalytics.getInstance().addFirebaseEvent(
  name: 'home_banner_click',
  parameters: {
    'banner_id': 'banner_001',
    'position': 1,
  },
);
```

`addFirebaseEvent()` 只接收 Firebase 需要的事件名和参数，并返回 Firebase 上报的 `Future<void>`。事件名超过 40 个字符时，Debug 模式会触发断言。

未初始化或当前 category 未启用 Firebase 时，该方法抛出 `StateError`。

## 业务 API 上报

```dart
QsEventAnalytics.getInstance().addApiEvent(
  code: 'home_banner',
  name: '首页 Banner',
  type: QsApiEventType.click,
  belongPage: 'home',
  extra: const {
    'bannerId': 'banner_001',
    'position': '1',
  },
  onSuccess: () {
    debugPrint('API 埋点成功');
  },
  onError: () {
    debugPrint('API 埋点失败');
  },
);
```

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| `code` | `String` | 事件编码 |
| `name` | `String` | 事件名称 |
| `type` | `QsApiEventType` | 业务事件类型 |
| `timestamp` | `int?` | 可选毫秒时间戳，默认使用当前时间 |
| `belongPage` | `String?` | 所属页面，允许为 `null` |
| `extra` | `Map<String, String>?` | 业务扩展参数 |
| `onSuccess` | `VoidCallback` | 业务 API 返回 `code == 0` 时调用 |
| `onError` | `VoidCallback` | 请求异常或业务 API 返回失败时调用 |

未初始化或当前 category 未启用 API 时，`addApiEvent()` 抛出 `StateError`。

## 页面事件

使用 `QsApiEventType.pageIn` 上报新页面时，如果已有当前页面，插件会先自动补发上一页面的 `pageOut`，其时间戳为新事件时间戳减 1 毫秒。自动生成的页面退出事件只走业务 API，不会生成 Firebase 事件。

```dart
QsEventAnalytics.getInstance().addApiEvent(
  code: 'home',
  name: '首页',
  type: QsApiEventType.pageIn,
  belongPage: 'home',
  onSuccess: () {},
  onError: () {},
);
```

可以保存和恢复当前页面：

```dart
final analytics = QsEventAnalytics.getInstance();
final pageData = analytics.getCurrentPageData();

analytics.returnToCurrentPage(pageData: pageData);
```

`returnToCurrentPage()` 属于 API 通道行为，API 通道未启用时会抛出 `StateError`。

## 事件类型

| 类型 | 业务接口编码 | 事件名称前缀 |
| --- | --- | --- |
| `QsApiEventType.appIn` | `in` | 原名称 |
| `QsApiEventType.appOut` | `out` | 原名称 |
| `QsApiEventType.pageIn` | `in` | `进入-【名称】` |
| `QsApiEventType.pageOut` | `out` | `离开-【名称】` |
| `QsApiEventType.click` | `click` | `点击-名称` |
| `QsApiEventType.valueChange` | `click` | `值改变-名称` |
| `QsApiEventType.load` | `load` | `加载-名称` |
| `QsApiEventType.show` | `in` | `显示-【名称】` |
| `QsApiEventType.close` | `out` | `关闭-【名称】` |
| `QsApiEventType.state` | `load` | `状态-名称` |
| `QsApiEventType.error` | `error` | `错误-名称` |

`QsApiEventType` 只用于业务 API。Firebase 事件名由调用方直接传给 `addFirebaseEvent()`。

## 失败重试

API 上报失败时，未包含在 `ignoreFailedEventCodes` 中的事件会写入本地 SQLite 数据库。网络恢复后插件自动补发，成功后删除对应记录。

失败队列使用 `qs_api_failed_event.db` 数据库和 `qs_api_failed_event_table` 数据表，字段为 `event_id`、`event_data`。事件 JSON 使用 `session_id`、`event_code`、`event_name`、`event_type`、`event_time`、`belong_page`、`extra`。旧 `analytic_error.db` 不再读取或迁移，也不会被插件主动删除。

失败队列仅属于 API 通道：

- Firebase 事件不会写入失败队列；
- 仅 Firebase 模式不会启动网络监听；
- 当前 category 未启用 API 时不会执行队列补发。

## 会话 ID

```dart
final analytics = QsEventAnalytics.getInstance();

final sessionId = analytics.sessionId;
analytics.updateSessionId();
```

## 从旧接口迁移

旧版统一的 `addEvent()` 已移除：

- Firebase 事件改用 `addFirebaseEvent()`；
- 业务接口事件改用 `addApiEvent()`；
- 原公开 `recordEvent()` 已改为插件内部私有实现；
- 初始化参数分别放入 `QsFirebaseConfig` 和 `QsApiConfig`；
- `QsEventCategory.all` 模式下需要分别调用两个上报方法。

## 注意事项

- 必须先完成 `initialize()` 再调用上报方法。
- 插件按单例设计，建议每次 App 运行只初始化一次。
- API 通道会读取网络状态、IP 信息并使用本地数据库，请按业务合规要求完善隐私政策。
- 当前失败补发没有互斥、去重、重试次数上限或退避策略，不能保证事件只发送一次。
