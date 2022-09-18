import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  FirebaseAuth _auth;
  bool shouldHidePassword = true;
  bool showSpinner = false;
  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: "bolt",
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  prefixIcon: Icon(Icons.person, color: Colors.black54),
                  hintText: "Enter your Email.",
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
                obscureText: shouldHidePassword,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: "Enter your Password.",
                    prefixIcon: Icon(Icons.lock, color: Colors.black54),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          shouldHidePassword = !shouldHidePassword;
                        });
                      },
                      icon: Icon(
                          shouldHidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54),
                    )),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundButton(
                buttonColor: Colors.blueAccent,
                buttonName: 'Register',
                onPressed: () async {
                  //Registration functionality.
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                  } catch (e) {
                    print(e);
                  }
                  try {
                    final currentUser = await _auth.currentUser();
                    if (currentUser != null) {
                      Navigator.pushNamed(
                        context,
                        ChatScreen.id,
                      );
                    }
                  } on Exception catch (e) {
                    print(e);
                  }
                  setState(() {
                    showSpinner = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
