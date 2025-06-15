import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleOAuthConfig {
  static String get clientId {
    if (kIsWeb) {
      // 웹의 경우 iOS 클라이언트 ID 사용
      return const String.fromEnvironment(
        'GOOGLE_CLIENT_ID_IOS',
        defaultValue: '1044566673280-do2e4djvupar175pb91eujbi4jjjeo0e.apps.googleusercontent.com',
      );
    } else if (Platform.isIOS) {
      return const String.fromEnvironment(
        'GOOGLE_CLIENT_ID_IOS',
        defaultValue: '1044566673280-do2e4djvupar175pb91eujbi4jjjeo0e.apps.googleusercontent.com',
      );
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment(
        'GOOGLE_CLIENT_ID_ANDROID',
        defaultValue: '1044566673280-m9hipqat2gam4djgfo7aireb2kfv1iad.apps.googleusercontent.com',
      );
    }
    
    // 기본값 (iOS)
    return '1044566673280-do2e4djvupar175pb91eujbi4jjjeo0e.apps.googleusercontent.com';
  }
}