import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_notify_demo/config/setting.dart';
import 'package:firebase_notify_demo/models/ui_helper.dart';
import 'package:firebase_notify_demo/models/user_model.dart';
import 'package:firebase_notify_demo/views/home_screen.dart';
import 'package:firebase_notify_demo/views/signup.dart';
import 'package:firebase_notify_demo/widgets/widget.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == '' || password == '') {
      UIHelper.showAlertDialog(context, 'Incomplete data', 'Please fill all the fields');
    } else {
      signIn(email, password);
    }
  }

  void signIn(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, 'Signing In');

    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(e) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, 'An error occured', e.message.toString());
    }

    if(credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);

      //go to homepage
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen(userModel: userModel, firebaseUser: credential!.user!)), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Talk', style: TextStyle(fontSize: 60, color: Setting.themeColor)),
                      Text('Tube™', style: TextStyle(fontSize: 60, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: textFieldInputDecoration('Email'),
                  style: simpleTextStyle(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: textFieldInputDecoration('Password'),
                  style: simpleTextStyle(),
                ),
                const SizedBox(height: 8),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                      onTap: () {},
                      child: Text('Forgot password?', style: simpleTextStyle())
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      checkValues();
                    },
                    child: const Text('Sign In'),
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
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Sign In with Google', style: TextStyle(color: Colors.black)),
                    style: ButtonStyle(
                      // overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.1)),
                        backgroundColor: MaterialStateProperty.all(const Color(0xffe0e0e0)),
                        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(12)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)))
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have a account?\t", style: simpleTextStyle()),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp())),
                        child: const Text("Register now", style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}