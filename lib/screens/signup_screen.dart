import 'package:jupiter_clone/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jupiter_clone/widgets/reusable_widget.dart';
import 'package:jupiter_clone/home_dir/home_screen.dart';
import 'package:jupiter_clone/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../widgets/reusable_widget.dart';
import '../utils/color_utils.dart';
import '../home_dir/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  void showSuccess(){
    QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Account created successfully!',
        text: 'Sign In to continue'
    );
  }
  void showError1(){
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: 'Account already exists!',
    );
  }
  void showError(){
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: 'Password should contain at least 6 Characters!',
    );
  }
  void showError2(){
    QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'The email address is badly formated!',
        );
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                // const SizedBox(
                //   height: 20,
                // ),
                // reusableTextField("Enter UserName", Icons.person_outline, false,
                //     _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Email Id", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outlined, true,
                    _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "Sign Up", () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
                    print("Created New Account");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignInScreen()));
                  }).onError((error, stackTrace) {
                    if(error.toString() == "[firebase_auth/email-already-in-use] The email address is already in use by another account.")showError1();
                    else if(error.toString() == "[firebase_auth/invalid-email] The email address is badly formatted.")showError2();
                    else showError();
                    print("Error ${error.toString()}");
                  });
                })
              ],
            ),
          ))),
    );
  }
}
