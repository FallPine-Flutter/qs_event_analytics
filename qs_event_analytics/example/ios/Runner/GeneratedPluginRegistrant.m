//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<connectivity_plus/ConnectivityPlusPlugin.h>)
#import <connectivity_plus/ConnectivityPlusPlugin.h>
#else
@import connectivity_plus;
#endif

#if __has_include(<firebase_analytics/FirebaseAnalyticsPlugin.h>)
#import <firebase_analytics/FirebaseAnalyticsPlugin.h>
#else
@import firebase_analytics;
#endif

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
@import firebase_core;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

#if __has_include(<ip_location/IpLocationPlugin.h>)
#import <ip_location/IpLocationPlugin.h>
#else
@import ip_location;
#endif

#if __has_include(<net_dio_request/NetDioRequestPlugin.h>)
#import <net_dio_request/NetDioRequestPlugin.h>
#else
@import net_dio_request;
#endif

#if __has_include(<qs_event_analytics/QsEventAnalyticsPlugin.h>)
#import <qs_event_analytics/QsEventAnalyticsPlugin.h>
#else
@import qs_event_analytics;
#endif

#if __has_include(<qs_storage_tool/QsStorageToolPlugin.h>)
#import <qs_storage_tool/QsStorageToolPlugin.h>
#else
@import qs_storage_tool;
#endif

#if __has_include(<qs_toast/QsToastPlugin.h>)
#import <qs_toast/QsToastPlugin.h>
#else
@import qs_toast;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<sqflite_darwin/SqflitePlugin.h>)
#import <sqflite_darwin/SqflitePlugin.h>
#else
@import sqflite_darwin;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [ConnectivityPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"ConnectivityPlusPlugin"]];
  [FirebaseAnalyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FirebaseAnalyticsPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
  [IpLocationPlugin registerWithRegistrar:[registry registrarForPlugin:@"IpLocationPlugin"]];
  [NetDioRequestPlugin registerWithRegistrar:[registry registrarForPlugin:@"NetDioRequestPlugin"]];
  [QsEventAnalyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"QsEventAnalyticsPlugin"]];
  [QsStorageToolPlugin registerWithRegistrar:[registry registrarForPlugin:@"QsStorageToolPlugin"]];
  [QsToastPlugin registerWithRegistrar:[registry registrarForPlugin:@"QsToastPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [SqflitePlugin registerWithRegistrar:[registry registrarForPlugin:@"SqflitePlugin"]];
}

@end
