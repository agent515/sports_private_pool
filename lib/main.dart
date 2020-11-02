import 'package:flutter/material.dart';
import 'screens/main_frame_app.dart';
import 'screens/welcome_screen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

bool userLoggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
  await pathProvider.getApplicationDocumentsDirectory();
  await Hive.init(appDocumentDirectory.path);

  await Hive.openBox('userData');
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
