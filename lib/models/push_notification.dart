import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:io';
import 'package:sports_private_pool/services/firebase.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

class PushNotification {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
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

  void initializeFCM() async {
    /// Create a [AndroidNotificationChannel] for heads up notifications
    AndroidNotificationChannel channel;

    /// Initialize the [FlutterLocalNotificationsPlugin] package.
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      if (Platform.isIOS) await requestNotificationPermission();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final IOSInitializationSettings initializationSettingsIOS =
          IOSInitializationSettings(
              onDidReceiveLocalNotification: onDidReceiveLocalNotification);
      const MacOSInitializationSettings initializationSettingsMacOS =
          MacOSInitializationSettings();
      final InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsIOS,
              macOS: initializationSettingsMacOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: selectNotification);

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await saveDeviceToken();
    }

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        // Navigator.pushNamed(
        //   context,
        //   '/message',
        //   arguments: MessageArguments(message, true),
        // );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });
  }

  Future onDidReceiveLocalNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {}

  Future<void> requestNotificationPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      Map<String, dynamic> jsonData = json.decode(payload);
      // if (jsonData['data']['type'] == 'question') {
      //   return navigateToQuestion(jsonData['data']['questionId']);
      // }
      // if (jsonData['data']['type'] == 'assignment') {
      //   return navigateToAssignment(jsonData['data']['assignmentId']);
      // }
    }
    // return navigationService.navigateTo(Routes.homeRoute);
  }

  Future<void> saveDeviceToken() async {
    final currentToken = await _messaging.getToken();
    await _firebase.saveDeviceToken(currentToken);
  }
}
