// import 'dart:html';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:pastry/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pastry/models/user.dart';

class LoginScreen extends StatefulWidget {
  final isMobile;

  const LoginScreen({Key? key, this.isMobile}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  List<Tab> tabList = [Tab(text: "Вход"), Tab(text: "Регистрация")];
  late TabController _tabController;

  double getScreenWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = getScreenWidth(context) < 420;
    Widget login = Scaffold(
        appBar: AppBar(
            bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(
              decoration:
                  new BoxDecoration(color: Theme.of(context).primaryColor),
              child: TabBar(controller: _tabController, tabs: tabList)),
        )),
        // PreferredSize(
        //   preferredSize: Size.fromHeight(kToolbarHeight),
        //   child: Container(
        //             decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
        //             child: SafeArea(child: TabBar(controller: _tabController, tabs: tabList))),
        // ),
        body: TabBarView(
          children: tabList.map((tab) => _getTab(tab, isMobile)).toList(),
          controller: _tabController,
        ));
    // Container(
    //     child: Column(children: [
    //   Container(
    //       decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
    //       child: TabBar(controller: _tabController, tabs: tabList)),
    //   Expanded(
    //     child: TabBarView(
    //       children: tabList.map((tab) => _getTab(tab)).toList(),
    //       controller: _tabController,
    //     ),
    //   )
    // ]));
    // Widget login = loginMobileDevicesWidget;
    // if (!widget.isMobile) {
    if (!isMobile) {
      login = Scaffold(
          body: Container(
        color: Colors.grey,
        child: Center(
          child: Container(
            width: 808,
            height: 600,
            child: Card(
              child: Row(
                children: [
                  Stack(
                    children: [
                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ).createShader(
                              Rect.fromLTRB(0, -140, rect.width, rect.height));
                        },
                        blendMode: BlendMode.darken,
                        child: Container(
                          // color: Colors.deepOrange,
                          width: 400,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('images/cookie_light2.jpg'),
                                  fit: BoxFit.cover)),
                        ),
                      ),
                      Container(child: row1, width: 400)
                    ],
                  ),
                  Container(
                    width: 400,
                    child: Column(children: [
                      Container(
                          decoration: new BoxDecoration(
                              color: Theme.of(context).primaryColor),
                          child: TabBar(
                              controller: _tabController, tabs: tabList)),
                      Expanded(
                        child: TabBarView(
                          children: tabList
                              .map((tab) => _getTab(tab, isMobile))
                              .toList(),
                          controller: _tabController,
                        ),
                      )
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }
    return login;
  }

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: tabList.length);
    super.initState();
  }
}

Widget loginMobileDevicesWidget =
    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  getCardWrapper(SocialsForm(), 16, 0, 8),
  getDivider(30, "или"),
  getCardWrapper(EmailPasswordForm(), 16, 0, 8)
]);

Widget _getTab(Tab tab, bool isMobile) {
  Widget loginTab = loginMobileDevicesWidget;
  bool isMobileDevice = isMobile;
  if (!isMobileDevice) {
    loginTab = EmailPasswordForm(buttonHeight: 50, isMobile: isMobileDevice);

    loginTab =
        Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: loginTab);
  }
  if (tab.text == 'Регистрация') {
    loginTab = Padding(
      padding: const EdgeInsets.all(8.0),
      child: RegistrationForm(),
    );
  }
  return loginTab;
  // switch (tab.text) {
  //   case 'Вход':
  //     return loginWebTab;
  //   case 'Регистрация':
  //     return loginMobileDevicesWidget;
  //   default:
  //     return loginWebTab;
  // }
}

Widget loginWebTab = Column(
    // mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // CircleAvatar(
      //     backgroundImage: Image.asset("images/pastry.png").image,
      //     radius: 50,
      //     backgroundColor: Colors.indigo),
      // SizedBox(
      //   height: 16,
      // ),
      // getDivider(60, "или"),
      EmailPasswordForm(buttonHeight: 50)
    ]);

class EmailPasswordForm extends StatefulWidget {
  final double? spaceSize;
  final double buttonHeight;
  final bool isMobile;

  const EmailPasswordForm(
      {Key? key,
      this.spaceSize = 8,
      this.buttonHeight = 40,
      this.isMobile = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => EmailPasswordFormState();
}

class EmailPasswordFormState extends State<EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration:
                InputDecoration(labelText: 'E-mail', filled: widget.isMobile),
            validator: (value) => EmailValidator.validate(value!)
                ? null
                : 'Введите корректный email',
          ),
          SizedBox(height: widget.spaceSize),
          TextFormField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
                labelText: 'Пароль',
                enabledBorder: UnderlineInputBorder(),
                filled: widget.isMobile),
            obscureText: true,
          ),
          SizedBox(height: widget.spaceSize),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, widget.buttonHeight)),
            child: Text('Войти'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _signInWithEmailAndPassword();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code of how to sign in with email and password.
  Future<void> _signInWithEmailAndPassword() async {
    try {
      final User? user = (await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;

      // Scaffold.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('${user!.email} signed in'),
      //   ),
      // );
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign in with Email & Password'),
        ),
      );
    }
  }
}

class RegistrationForm extends StatefulWidget {
  final double? spaceSize;
  final double buttonHeight;
  final bool isMobile;

  const RegistrationForm(
      {Key? key,
      this.spaceSize = 8,
      this.buttonHeight = 40,
      this.isMobile = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => RegistrationFormState();
}

class RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration:
                InputDecoration(labelText: 'E-mail', filled: widget.isMobile),
            validator: (value) => EmailValidator.validate(value!)
                ? null
                : 'Введите корректный email',
          ),
          SizedBox(height: widget.spaceSize),
          TextFormField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
                labelText: 'Пароль',
                enabledBorder: UnderlineInputBorder(),
                filled: widget.isMobile),
            obscureText: true,
          ),
          SizedBox(height: widget.spaceSize),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, widget.buttonHeight)),
            child: Text('Зарегистрироваться'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _registerWithEmailAndPassword();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code of how to sign in with email and password.
  Future<void> _registerWithEmailAndPassword() async {
    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      await AppUser.fromAuthUser(credential.user!).toFirestore();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Зарегистрировано'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorText = e.toString();
      if (e.code == 'weak-password') {
        errorText = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorText = 'The account already exists for that email.';
      }
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
        ),
      );
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}

class SocialsForm extends StatelessWidget {
  const SocialsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Войдите с помощью социальных сетей',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SignInButtonBuilder(
                  icon: FontAwesomeIcons.google,
                  backgroundColor: Colors.red,
                  onPressed: () {},
                  text: '',
                  mini: true,
                  shape: CircleBorder(),
                  width: 45,
                ),
                SignInButtonBuilder(
                  icon: FontAwesomeIcons.apple,
                  backgroundColor: Colors.black,
                  onPressed: () {},
                  text: '',
                  mini: true,
                  shape: CircleBorder(),
                  width: 45,
                ),
                SignInButtonBuilder(
                  icon: FontAwesomeIcons.facebookF,
                  backgroundColor: Colors.indigo,
                  onPressed: () {},
                  text: '',
                  mini: true,
                  shape: CircleBorder(),
                  width: 45,
                ),
                SignInButtonBuilder(
                  icon: FontAwesomeIcons.twitter,
                  backgroundColor: Color(0xFF1DA1F2),
                  onPressed: () {},
                  text: '',
                  mini: true,
                  shape: CircleBorder(),
                  width: 45,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget getCardWrapper(Widget widget, double horizontalMargin,
    double verticalMargin, double padding) {
  return Card(
      margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin, vertical: verticalMargin),
      child: Padding(padding: EdgeInsets.all(padding), child: widget));
}

Widget getDivider(double height, String middleText) {
  return Row(children: [
    Expanded(
      child: new Container(
          margin: const EdgeInsets.only(left: 10.0, right: 20.0),
          child: Divider(
            color: Colors.black,
            height: height,
          )),
    ),
    Text(middleText),
    Expanded(
      child: new Container(
          margin: const EdgeInsets.only(left: 20.0, right: 10.0),
          child: Divider(
            color: Colors.black,
            height: height,
          )),
    ),
  ]);
}

Widget row1 = Container(
    child: Padding(
  padding: EdgeInsets.all(40),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.topLeft,
            child: Text(
              "Pastry",
              style: TextStyle(
                fontSize: 80,
                color: Colors.red[300],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.topLeft,
            child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean gravida.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red[400],
                )),
          )
        ],
      ),
      SocialsForm(),
    ],
  ),
));
