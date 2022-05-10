import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notify_demo/models/firebase_helper.dart';
import 'package:firebase_notify_demo/models/user_model.dart';
import 'package:firebase_notify_demo/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import './views/signin.dart';
import './services/local_notification_service.dart';

var uuid = Uuid();

///Receive message when app is in background solution for on message
Future<void> backgroundHandler(RemoteMessage message) async {
  // ignore: avoid_print
  print(message.data.toString());
  // ignore: avoid_print
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    UserModel? thisUser = await FirebaseHelper.getUserModelById(currentUser.uid);
    thisUser != null
    ? runApp(MyAppLoggedIn(userModel: thisUser, firebaseUser: currentUser))
    : runApp(const MyApp());
  } else {
    runApp(const MyApp());
  }
  // runApp(const MyApp());
}

/// Not logged in
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeUp Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xff1f1f1f),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/// Already logged in
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeUp Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xff1f1f1f),
      ),
      home: HomeScreen(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    LocalNotificationService.initialize(context);

    ///terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if(message!=null){
        final routeFromMessage = message.data['route'];
        Navigator.of(context).pushNamed(routeFromMessage);
      }
    });

    ///foreground work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null){
        // ignore: avoid_print
        print(message.notification!.body);
        // ignore: avoid_print
        print(message.notification!.title);

        final routeFromMessage = message.data['route'];
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text(message.notification!.title.toString()),
            content: Text(message.notification!.title.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed(routeFromMessage), child: const Text('Details')),
              TextButton(onPressed: () => Navigator.of(context).pushNamed(routeFromMessage), child: const Text('Not replacement')),
            ],
          );
        });
      }

      LocalNotificationService.display(message);
    });

    ///When apps running in the background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data['route'];

      Navigator.of(context).pushNamed(routeFromMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You will receive message soon',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn()));},
                  child: const Text("Let's talk")
              ),
              const SizedBox(height: 40),
              /*ElevatedButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const CompleteProfile()));},
                  child: const Text("Edit profile")
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
