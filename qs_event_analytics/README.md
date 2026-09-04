# qs_event_analytics

`qs_event_analytics` 是一个 Flutter 轨迹打点分析插件，用于在应用内统一上报 App、页面、点击、曝光、状态、错误等事件。

插件会同时完成两类上报：

- 通过 `Firebase Analytics` 记录事件；
- 通过业务接口上报事件明细，并在接口失败时将事件暂存到本地数据库，网络恢复后自动重试。

## 安装

在业务项目的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  qs_event_analytics: ^1.1.1
```

如果使用本地路径调试：

```yaml
dependencies:
  qs_event_analytics:
    path: ../qs_event_analytics
```

然后执行：

```bash
flutter pub get
```

## 前置配置

插件依赖 Firebase，请先在业务项目中完成 Firebase 初始化配置。

常见配置包括：

- Android：添加 `google-services.json`；
- iOS：添加 `GoogleService-Info.plist`；
- 按 Firebase 要求配置 Android / iOS 工程。

如果业务项目已经在别处初始化过 Firebase，可在调用本插件初始化时传入同一套 `FirebaseOptions`，或根据项目现有方式处理。

## 导入

当前埋点 API 位于 `analytic_tool.dart` 和 `analytic_model.dart`：

```dart
import 'package:qs_event_analytics/analytic_tool.dart';
import 'package:qs_event_analytics/analytic_model.dart';
```

## 初始化

建议在应用启动后尽早初始化，例如 `main()` 或登录成功后：

```dart
import 'package:flutter/material.dart';
import 'package:qs_event_analytics/analytic_tool.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AnalyticTool.getInstance().initialize(
    userid: 'user_001',
    api: 'https://example.com/api/event/report',
    systemVersion: 'iOS 17.0',
    appVersion: '1.0.0',
    ignoreFailedEventCodes: const [],
  );

  runApp(const MyApp());
}
```

参数说明：

| 参数 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `userid` | `String` | 是 | 当前用户唯一标识，上报时对应 `uuid` |
| `api` | `String` | 是 | 业务埋点上报接口地址 |
| `systemVersion` | `String` | 是 | 系统版本 |
| `appVersion` | `String` | 是 | App 版本 |
| `ignoreFailedEventCodes` | `List<String>` | 是 | 接口上报失败时不需要写入本地重试队列的事件 code |
| `options` | `FirebaseOptions?` | 否 | Firebase 初始化参数 |

## 上报事件

使用 `AnalyticTool.getInstance().addEvent()` 上报事件：

```dart
AnalyticTool.getInstance().addEvent(
  code: 'home_banner',
  name: '首页 Banner',
  type: EventType.click,
  belongPage: 'home',
  extra: {
    'bannerId': 'banner_001',
    'position': '1',
  },
  onSuccess: () {
    debugPrint('埋点上报成功');
  },
  onError: () {
    debugPrint('埋点上报失败');
  },
);
```

参数说明：

| 参数 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| `code` | `String` | 是 | 事件编码 |
| `name` | `String` | 是 | 事件名称 |
| `type` | `EventType` | 是 | 事件类型 |
| `timestamp` | `int?` | 否 | 事件时间戳，默认使用当前毫秒时间戳 |
| `belongPage` | `String?` | 是 | 事件归属页面 code |
| `extra` | `Map<String, String>?` | 否 | 自定义扩展参数 |
| `onSuccess` | `VoidCallback` | 是 | 业务接口上报成功回调 |
| `onError` | `VoidCallback` | 是 | 业务接口上报失败回调 |

## 页面进出

进入页面时上报 `EventType.pageIn`：

```dart
AnalyticTool.getInstance().addEvent(
  code: 'home',
  name: '首页',
  type: EventType.pageIn,
  belongPage: 'home',
  extra: {
    'source': 'tab',
  },
  onSuccess: () {},
  onError: () {},
);
```

当新的 `pageIn` 事件发生时，插件会自动为上一个页面补发一条 `pageOut` 事件。

离开应用或需要手动记录退出时，也可以直接上报：

```dart
AnalyticTool.getInstance().addEvent(
  code: 'home',
  name: '首页',
  type: EventType.pageOut,
  belongPage: 'home',
  onSuccess: () {},
  onError: () {},
);
```

## 保存和恢复当前页面

插件会记录当前页面信息。需要临时离开并恢复页面打点时，可以使用：

```dart
final pageData = AnalyticTool.getInstance().getCurrentPageData();

// 稍后恢复当前页面
AnalyticTool.getInstance().returnToCurrentPage(pageData: pageData);
```

## 会话 ID

插件初始化时会自动生成一个 `sessionId`。如果业务需要在登录、登出、重新进入 App 等场景切换会话，可以调用：

```dart
AnalyticTool.getInstance().updateSessionId();
```

获取当前会话 ID：

```dart
final sessionId = AnalyticTool.getInstance().sessionId;
```

## 事件类型

| 类型 | 说明 | 业务接口 `eventType` | Firebase 后缀 |
| --- | --- | --- | --- |
| `EventType.appIn` | App 进入 | `in` | `in` |
| `EventType.appOut` | App 退出 | `out` | `out` |
| `EventType.pageIn` | 页面进入 | `in` | `in` |
| `EventType.pageOut` | 页面离开 | `out` | `out` |
| `EventType.click` | 点击 | `click` | `clk` |
| `EventType.valueChange` | 值改变 | `click` | `vc` |
| `EventType.load` | 加载 | `load` | `ld` |
| `EventType.show` | 显示 / 曝光 | `in` | `in` |
| `EventType.close` | 关闭 | `out` | `out` |
| `EventType.state` | 状态 | `load` | 空字符串 |
| `EventType.error` | 错误 | `error` | `err` |

## 业务接口数据格式

插件会使用 `POST JSON` 调用初始化时传入的 `api`，参数如下：

| 字段 | 说明 |
| --- | --- |
| `sessionId` | 当前会话 ID |
| `uuid` | 初始化传入的 `userid` |
| `eventCode` | 事件编码 |
| `eventName` | 根据事件类型生成的事件名称 |
| `eventType` | 事件类型编码 |
| `eventTime` | 事件毫秒时间戳 |
| `userIp` | IP 地址 |
| `countryCode` | 国家 / 地区 |
| `cityCode` | 城市 |
| `systemVersion` | 初始化传入的系统版本 |
| `appVersion` | 初始化传入的 App 版本 |
| `attrPage` | 归属页面 |
| `eventContent` | `extra` 序列化后的 JSON 字符串 |
| `env` | Debug / Profile 为 `dev`，Release 为 `prd` |

接口返回的 JSON 中 `code == 0` 会被视为上报成功，否则视为失败。

## 失败重试

通过 `addEvent()` 上报业务接口失败时，未被 `ignoreFailedEventCodes` 排除的事件会写入本地 `sqflite` 数据库 `analytic_error.db` 的 `analytic_error_table` 表。记录包含主键 `id` 和事件 JSON 字符串 `data`，不包含失败原因或重试次数。Firebase 上报不使用这套本地失败队列。

收到网络已连接的通知时（包括初始化网络检查和后续网络状态变化），插件会自动读取失败队列并重新上报；重试成功后按记录主键删除本地数据，失败则保留，等待后续触发。当前没有定时重试、重试次数上限或退避策略。

版本修复说明：

- `1.1.0`：修复失败事件写入数据库时的序列化问题。
- `1.1.1`：修复读取失败记录时未恢复 `id`，导致补发成功后无法删除、后续可能重复补发的问题。已有数据库记录无需迁移或清空，补发成功后按原有主键删除。

建议使用失败重试功能的项目升级到 `1.1.1` 或更高版本。

如果某些事件不需要失败重试，可在初始化时传入 `ignoreFailedEventCodes`：

```dart
await AnalyticTool.getInstance().initialize(
  userid: 'user_001',
  api: 'https://example.com/api/event/report',
  systemVersion: 'iOS 17.0',
  appVersion: '1.0.0',
  ignoreFailedEventCodes: const ['heartbeat'],
);
```

## Firebase 事件名

插件会上报 Firebase 事件名：

```text
{code}_{firebaseTypeCode}
```

例如：

```text
home_banner_clk
```

注意：Firebase 事件名长度不能超过 40 个字符。插件内部包含断言校验，建议控制 `code` 长度。

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:qs_event_analytics/analytic_model.dart';
import 'package:qs_event_analytics/analytic_tool.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    AnalyticTool.getInstance().addEvent(
      code: 'home',
      name: '首页',
      type: EventType.pageIn,
      belongPage: 'home',
      onSuccess: () {},
      onError: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AnalyticTool.getInstance().addEvent(
              code: 'home_confirm_button',
              name: '确认按钮',
              type: EventType.click,
              belongPage: 'home',
              extra: {
                'from': 'home',
              },
              onSuccess: () {},
              onError: () {},
            );
          },
          child: const Text('确认'),
        ),
      ),
    );
  }
}
```

## 注意事项

- 请在调用 `addEvent` 前完成 `initialize`。
- `extra` 当前建议使用 `Map<String, String>`，避免本地失败队列反序列化时丢失数据。
- `pageIn` 会触发上一页面的自动 `pageOut`，不要在同一时机重复手动上报上一页面离开事件。
- 插件会读取网络状态、IP 定位信息，并使用本地数据库保存失败事件，请按业务合规要求补充隐私政策说明。
