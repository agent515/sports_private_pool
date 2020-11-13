import 'package:flutter/material.dart';
import 'screens/main_frame_app.dart';
import 'screens/welcome_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'models/person.dart';

bool userLoggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
  await pathProvider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(PersonAdapter());


  SharedPreferences preferences = await SharedPreferences.getInstance();
  userLoggedIn = preferences.getString('email') != null;
  print("EMAIL: ${preferences.getString('email')}");

  await Hive.openBox<dynamic>('userData');
  await Hive.openBox<Person>('user');
  runApp(Envision());
}


class Envision extends StatefulWidget {
  @override
  _EnvisionState createState() => _EnvisionState();
}

class _EnvisionState extends State<Envision> {

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        final joinCode = deepLink.queryParameters["joinCode"];
        print(deepLink.queryParameters);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainFrameApp(defaultPage: 1, joinCode: joinCode,),
          ),
        );
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(accentColor: Colors.black87),

      initialRoute: userLoggedIn ? 'MainFrameApp' : 'WelcomeScreen',
      routes: {
        'WelcomeScreen' : (context) => WelcomeScreen(),
        'LoginScreen': (context) => LoginScreen(),
        'RegisterScreen' : (context) => RegisterScreen(),
        'MainFrameApp' : (context) => MainFrameApp(),
      },
      );
  }
}
