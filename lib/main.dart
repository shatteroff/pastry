import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pastry/screens/main_screen_mobile.dart';
import 'package:pastry/screens/login/login.dart';

import 'generated/l10n.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

bool get isMobileDevice => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print(isMobileDevice);
  runApp(App());
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
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
    Widget body = LoginScreen(isMobile: isMobileDevice);
    if (_user != null) {
      // print(_user);
      // print(auth.currentUser);
      body = MyStatefulWidget();
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
}

// class MainScreen extends StatelessWidget {
//   const MainScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // if (_auth.currentUser != null) {
//     return Container(
//       child: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             _auth.signOut();
//           },
//           child: Text('sign out'),
//         ),
//       ),
//     );
//     // } else {
//     //   return loginScreen;
//     // }
//   }
// }

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
