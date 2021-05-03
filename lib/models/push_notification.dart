import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:io';
import 'package:sports_private_pool/main.dart' as main;
import 'package:sports_private_pool/services/firebase.dart';

class PushNotification {
  final FirebaseMessaging _messaging = FirebaseMessaging();
  FirebaseRepository _firebase = FirebaseRepository();
  String title;
  String body;
  String joinCode;

  PushNotification({this.title, this.body});

  factory PushNotification.fromPayload(String payload) {
    return PushNotification.fromJson(json.decode(payload));
  }

  factory PushNotification.fromJson(Map<String, dynamic> jsonData) {
    return PushNotification(
      title: jsonData['notification']['title'],
      body: jsonData['notification']['body'],
    );
  }

  @override
  String toString() => "Title: $title, Body: $body";

  void initializeFCM() {
    if (Platform.isIOS) {
      _messaging.requestNotificationPermissions(IosNotificationSettings());
      _messaging.onIosSettingsRegistered.listen((_) {
        saveDeviceToken();
      });
    } else if (Platform.isAndroid) {
      saveDeviceToken();
    }

    _messaging.configure(
      onMessage: (message) async {
        showNotification(message);
      },
      onBackgroundMessage: backgroundLocalNotificationHandler,
      onLaunch: (message) async {
        showNotification(message);
      },
      onResume: (message) async {
        showNotification(message);
      },
    );
  }

  static Future<void> backgroundLocalNotificationHandler(
      Map<String, dynamic> message) async {
    print("In BackgroundLocalNotification");
  }

  Future<void> showNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.envision.Envision',
      'Envision',
      'A platform to create fantasy pools.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await main.flutterLocalNotificationsPlugin.show(
      0,
      message['title'],
      message['body'],
      platformChannelSpecifics,
      payload: json.encode(message),
    );
  }

  Future<void> saveDeviceToken() async {
    final currentToken = await _messaging.getToken();
    await _firebase.saveDeviceToken(currentToken);
  }
}
