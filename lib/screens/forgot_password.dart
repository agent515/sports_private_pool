import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sports_private_pool/components/rounded_button.dart';
import 'package:sports_private_pool/constants.dart';
import 'package:sports_private_pool/services/firebase.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailTextController = TextEditingController();
  String email;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseRepository _firebase = FirebaseRepository();
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 34.0, horizontal: 34.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'HERO',
              child: Container(
                height: 100.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            SizedBox(
              width: 250.0,
              child: ColorizeAnimatedTextKit(
                  speed: Duration(milliseconds: 300),
                  onTap: () {
                    print("Tap Event");
                  },
                  text: [
                    'E N V I S I O N',
                  ],
                  textStyle: TextStyle(
                    fontSize: 18.0,
                    fontFamily: "Horizon",
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [
                    Colors.black87,
                    Colors.grey,
                    Colors.white,
                  ],
                  textAlign: TextAlign.center,
                  alignment:
                      AlignmentDirectional.topStart // or Alignment.topLeft
                  ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: kTextInputFieldDecoration.copyWith(
                      prefixIcon: Icon(Icons.perm_identity),
                      hintText: "Email-id",
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 60.0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    validator: (inpEmail) {
                      if (inpEmail.isEmpty) return "Email cannot be empty.";
                      bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(inpEmail);
                      if (!emailValid) return "Enter valid email.";
                      return null;
                    },
                  ),
                  RoundedButton(
                      color: Colors.pink,
                      text: "Send Mail",
                      onpressed: () async {
                        if (_formKey.currentState.validate()) {
                          try {
                            await _firebase.forgotPassword(email);
                            print("email sent");
                            Navigator.pop(context);
                          } catch (e) {
                            if (Platform.isAndroid) {
                              switch (e.message) {
                                case 'There is no user record corresponding to this identifier. The user may have been deleted.':
                                  setState(() {
                                    errorMessage = "Email is not registerd";
                                  });
                                  break;
                                case 'The password is invalid or the user does not have a password.':
                                  setState(() {
                                    errorMessage = "Email is not registerd";
                                  });
                                  break;
                                case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
                                  setState(() {
                                    errorMessage = "Network Error: Try again";
                                  });
                                  break;
                                default:
                                  setState(() {
                                    errorMessage =
                                        "Sorry.\nThere was some problem. Try again.";
                                  });
                                  print(
                                      'Case ${e.message} is not yet implemented');
                              }
                              print(errorMessage);
                            }
                          }
                        }
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
