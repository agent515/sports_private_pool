import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_private_pool/models/authentication.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local_notification;

import 'models/person.dart';
import 'screens/main_frame_app.dart';
import 'screens/welcome_screen.dart';

bool userLoggedIn = false;
SharedPreferences preferences;

local_notification.FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin =
    local_notification.FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  preferences = await SharedPreferences.getInstance();

  final appDocumentDirectory =
      await pathProvider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(PersonAdapter());

  await Hive.openBox<dynamic>('userData');
  await Hive.openBox<Person>('user');

  // Flutter Local Notification
  var initializationSettingsAndroid =
      local_notification.AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = local_notification.IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String title, String body, String payload) async {},
  );
  var initializationSettings = local_notification.InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        try {
          print("notification payload: $payload");
          Map<String, dynamic> payloadJson = json.decode(payload);
          print(payloadJson);
          // if (payloadJson['data']['type'] == 'joinContest') {
          //   print(payloadJson['data']);
          //   print(navigatorKey.currentState.context);

          //   Navigator.push(
          //     navigatorKey.currentState.context,
          //     MaterialPageRoute(
          //       builder: (context) => MainFrameApp(
          //         defaultPage: 2,
          //         contestId: payloadJson['data']['contestId'],
          //         matchId: payloadJson['data']['matchId'],
          //       ),
          //     ),
          //   );
          // }
        } catch (e) {
          print(e);
        }
      } else {
        print("notification payload: $payload");
      }
    },
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => Authentication(),
      child: MaterialApp(
        title: 'Envision',
        navigatorKey: navigatorKey,
        theme: ThemeData(accentColor: Colors.black87),
        debugShowCheckedModeBanner: false,
        home: Envision(),
      ),
    ),
  );
}

class Envision extends StatefulWidget {
  @override
  _EnvisionState createState() => _EnvisionState();
}

class _EnvisionState extends State<Envision> {
  Box<Person> userBox;

  @override
  initState() {
    userBox = Hive.box('user');
    userLoggedIn = preferences.getString('email') != null;
    print("EMAIL: ${preferences.getString('email')}");

    Future.delayed(Duration.zero, () async {
      if (userLoggedIn) {
        Provider.of<Authentication>(context, listen: false)
            .login(userBox.get('user'));
      }
    });

    super.initState();
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        final joinCode = deepLink.queryParameters["joinCode"];
        print(deepLink.queryParameters);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainFrameApp(
              defaultPage: 1,
              joinCode: joinCode,
            ),
          ),
        );
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Authentication>(
      builder: (context, state, child) {
        if (state.loggedIn) {
          return MainFrameApp();
        }
        return WelcomeScreen();
      },
    );
  }
}
