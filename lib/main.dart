import 'package:flutter/material.dart';
import 'screens/main_frame_app.dart';
import 'screens/welcome_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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


class Envision extends StatelessWidget {
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
