import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pastry/screens/main/main_screen_mobile.dart';
import 'package:pastry/screens/login/login.dart';
import 'package:pastry/screens/main/main_screen_web.dart';

import 'generated/l10n.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;
// final FirebaseMessaging messaging = FirebaseMessaging.instance;

bool get isMobileDevice => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (isMobileDevice) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(MaterialApp(home: App()));
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  User? _user;

  @override
  void initState() {
    super.initState();
    // getToken();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
    if (isMobileDevice) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });
    }
  }

  double getScreenWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobileLayout = getScreenWidth(context) < 420;
    Widget body = LoginScreen(isMobile: isMobileDevice);
    if (_user != null) {
      // print(_user);
      // print(auth.currentUser);
      body = MainScreenMobileWidget();
      if (!isMobileLayout) {
        body = MainScreenWebWidget();
      }
    }
    return MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ru', '')
        ],
        title: 'Pastry',
        // initialRoute: '/',
        // routes: {
        //   '/': (context) => body,
        //   '/order': (context) => OrderRegistration()
        // },
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: body
        // Scaffold(
        // appBar: AppBar(
        //   title: Text('Pastry'),
        //   actions: (auth.currentUser == null)
        //       ? []
        //       : [
        //           IconButton(
        //               onPressed: () {
        //                 auth.signOut();
        //               },
        //               icon: Icon(Icons.exit_to_app))
        //         ],
        // ),
        // body: body,
        //   ),
        );
  }

// getToken() async {
//   String? token = await messaging.getToken();
//   print(token);
// }
}

TextEditingController emailController = new TextEditingController();
TextEditingController passwordController = new TextEditingController();

Widget loginScreen = Container(
    width: double.infinity,
    height: double.infinity,
    padding: EdgeInsets.all(20),
    child: Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'email'),
          controller: emailController,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'password'),
          controller: passwordController,
        ),
        ElevatedButton(
            onPressed: () async {
              try {
                UserCredential userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  print('No user found for that email.');
                } else if (e.code == 'wrong-password') {
                  print('Wrong password provided for that user.');
                }
              }
            },
            child: Text('click me'))
      ],
    )));
