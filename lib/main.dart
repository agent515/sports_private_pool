import 'package:flutter/material.dart';
import 'package:sports_private_pool/screens/home_page.dart';
import 'package:sports_private_pool/screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(Envision());


class Envision extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      initialRoute: WelcomeScreen.id,

      routes: {
        WelcomeScreen.id : (context) => WelcomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        RegisterScreen.id : (context) => RegisterScreen(),
        HomePage.id : (context) => HomePage(),
      },

    );
  }
}
