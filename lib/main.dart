import 'package:flutter/material.dart';
import 'package:sports_private_pool/screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

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
        darkTheme: ThemeData.dark(),

        initialRoute: WelcomeScreen.id,

        routes: {
          WelcomeScreen.id : (context) => WelcomeScreen(),
          LoginScreen.id : (context) => LoginScreen(),
          RegisterScreen.id : (context) => RegisterScreen(),
        },

      );
  }
}
