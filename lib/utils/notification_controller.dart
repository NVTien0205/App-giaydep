
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationController {
  // Khởi tạo Firebase và Firebase Messaging
  static Future<void> initializeNotifications({required bool debug}) async {
    await Firebase.initializeApp();

    // Cấu hình Firebase Messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Yêu cầu quyền thông báo trên iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (debug) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // Xử lý thông báo khi ứng dụng ở foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Bạn có thể hiển thị thông báo thủ công ở đây nếu muốn
      }
    });

    // Xử lý thông báo khi ứng dụng ở background hoặc terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Hàm lấy FCM Token của thiết bị
  Future<String> requestFirebaseToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('FCM Token: $token');
        }
        return token;
      }
    } catch (exception) {
      if (kDebugMode) {
        print('Error getting token: $exception');
      }
    }
    return '';
  }

  // Kiểm tra quyền thông báo
  Future<void> checkPermission() async {
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('Notification permission not granted');
      }
    }
  }

  // Không có local notification trực tiếp với firebase_messaging
  // Thay vào đó, bạn có thể gửi thông báo từ server qua FCM
  Future<void> localNotification() async {
    // Với Firebase Messaging, bạn không thể tạo local notification trực tiếp
    // Thay vào đó, bạn cần gửi thông báo từ server hoặc dùng package khác như flutter_local_notifications
    print('Local notifications are not supported directly with Firebase Messaging');
    print('Please use a server to send a push notification or add flutter_local_notifications');
  }

  // Hàm xử lý background message
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message notification: ${message.notification!.title}');
    }

    // Thực hiện tác vụ lâu dài nếu cần
    print("Starting long task");
    await Future.delayed(Duration(seconds: 4));
    print("Long task done");
  }
}

// Để sử dụng trong debug mode
const bool kDebugMode = true;
