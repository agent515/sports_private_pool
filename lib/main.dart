import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_private_pool/models/authentication.dart';

import 'models/person.dart';
import 'screens/main_frame_app.dart';
import 'screens/welcome_screen.dart';

bool userLoggedIn = false;
SharedPreferences preferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await pathProvider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(PersonAdapter());

  preferences = await SharedPreferences.getInstance();

  await Hive.openBox<dynamic>('userData');
  await Hive.openBox<Person>('user');
  runApp(ChangeNotifierProvider(
      create: (context) => Authentication(), child: Envision()));
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
    if (userLoggedIn)
      Provider.of<Authentication>(context, listen: false)
          .login(userBox.get('user'));

    return MaterialApp(
      theme: Theme.of(context).copyWith(accentColor: Colors.black87),
      debugShowCheckedModeBanner: false,
      home: Consumer<Authentication>(builder: (context, state, child) {
        if (state.loggedIn) {
          return MainFrameApp();
        }
        return WelcomeScreen();
      }),
    );
  }
}
