import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  void getCurrentUser() async {
    _user = await _auth.currentUser();
    if (_user != null) {
      Navigator.pushNamed(
        context,
        ChatScreen.id,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    animation = ColorTween(begin: Colors.red, end: Colors.red[400])
        .animate(animationController);
    animationController.addListener(() {
      setState(() {});
    });

    animationController.forward();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse(from: 1.0);
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: "bolt",
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60,
                  ),
                ),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w900,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Flash Chat',
                        speed: const Duration(milliseconds: 200),
                      )
                    ],
                    pause: Duration(seconds: 2),
                    repeatForever: true,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundButton(
                buttonColor: Colors.lightBlueAccent,
                buttonName: 'Log In',
                onPressed: () {
                  //Go to login screen.
                  Navigator.pushNamed(
                    context,
                    LoginScreen.id,
                  );
                }),
            RoundButton(
              buttonColor: Colors.blueAccent,
              buttonName: 'Register Now',
              onPressed: () {
                //Go to login screen.
                Navigator.pushNamed(
                  context,
                  RegistrationScreen.id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
