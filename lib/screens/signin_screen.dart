import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jupiter_clone/widgets/reusable_widget.dart';
import 'package:jupiter_clone/home_dir/home_screen.dart';
import 'package:jupiter_clone/screens/reset_password.dart';
import 'package:jupiter_clone/screens/signup_screen.dart';
import 'package:jupiter_clone/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;

import '../models/database_provider.dart';
import '../models/expense.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  void showError1(){
    QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Invalid Account or Password!',
        );
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/icons/logo1.png"),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter Email ID", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(
                  height: 5,
                ),
                forgetPassword(context),
                firebaseUIButton(context, "Sign In", () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) async {
                    final user = FirebaseAuth.instance.currentUser;
                    final storage = FirebaseStorage.instance;
                    final provider = Provider.of<DatabaseProvider>(context, listen: false);
                    try {
                      final ref = storage.ref().child(
                          'userdata/${user!.uid}.csv');
                      // // final file = File('${user.uid}.csv');
                      // final downloadUrl = await ref.getDownloadURL();
                      // final response = await http.get(Uri.parse(downloadUrl));
                      // final csvData = response.body;
                      // final csvRows = const CsvToListConverter().convert(csvData);
                      // final Directory? directory = await getExternalStorageDirectory();
                      // final String? documentPath = directory?.path;
                      //
                      // // Write the CSV to a file
                      // final File file = File('$documentPath/imported.csv');
                      // await file.writeAsString(csvData);

                      //final metadata = await ref.getMetadata();
                      // File exists, metadata available

                      final metadata = await ref.getMetadata();


                      if (metadata.fullPath == ref.fullPath) {
                        // File exists, metadata available
                        final downloadUrl = await ref.getDownloadURL();
                        final response = await http.get(Uri.parse(downloadUrl));
                        final csvData = response.body;
                        final csvRows = const CsvToListConverter().convert(
                            csvData);
                        final Directory? directory = await getExternalStorageDirectory();
                        final String? documentPath = directory?.path;

                        // Write the CSV to a file
                        final File file = File('$documentPath/imported.csv');
                        await file.writeAsString(csvData);
                        // final List<List<dynamic>> rowsAsMaps = const CsvToListConverter().convert(csvData);

                        await provider.updateDatabaseFromCsv(file);
                      }
                    }on FirebaseException catch (e) {
                      if (e.code == 'object-not-found') {
                        // no object exists at the desired reference, do something else

                        print("else here i am");
                        final Directory? directory = await getExternalStorageDirectory();
                        final String? documentPath = directory?.path;

                        // Write the CSV to a file
                        final File file = File('$documentPath/imported.csv');
                        await file.writeAsString('');
                        await provider.updateDatabaseFromCsv(file);
                      }
                      // final ref = storage.ref().child('userdata/');
                      // final file = File('${user!.uid}.csv');
                      // // await file.writeAsString('');
                      // await ref.putFile(file);

                      // final ref = storage.ref().child('userdata/${user!.uid}.csv');
                      // final metadata = await ref.getMetadata();
                      // if (!metadata.exists) {
                      //   // Create an empty CSV file
                      //   final File file = File('${user!.uid}.csv');
                      //   await file.writeAsString('');
                      //   await ref.putFile(file);
                      // }
                    }


                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  }).onError((error, stackTrace) {
                    showError1();
                    print("Error ${error.toString()}");
                  });
                }),
                signUpOption()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
}
