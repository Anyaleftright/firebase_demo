import 'dart:developer';

import 'package:firebase_notify_demo/config/setting.dart';
import 'package:firebase_notify_demo/models/ui_helper.dart';
import 'package:firebase_notify_demo/models/user_model.dart';
import 'package:firebase_notify_demo/views/complete_profile.dart';
import 'package:firebase_notify_demo/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if(email == '' || password == ''|| confirmPassword == '') {
      UIHelper.showAlertDialog(context, 'Incomplete data', 'Please fill all the fields');
    } else if (password != confirmPassword) {
      UIHelper.showAlertDialog(context, 'Incomplete data', 'Passwords does not match');
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, 'Signing up');

    try{
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(e) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, 'An error occured', e.message.toString());
    }

    if(credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(uid: uid, name: '', email: email, avatar: '');

      await FirebaseFirestore.instance.collection('users').doc(uid).set
        (newUser.toMap()).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Let's complete your profile.")));
        Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfile(userModel: newUser, firebaseUser: credential!.user!)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FlutterLogo(size: 150),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: textFieldInputDecoration('Email'),
                style: simpleTextStyle(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: textFieldInputDecoration('Password'),
                style: simpleTextStyle(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: textFieldInputDecoration('Confirm Password'),
                style: simpleTextStyle(),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: () => checkValues(),
                  child: const Text('Sign Up'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Setting.themeColor),
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(12)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)))
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
