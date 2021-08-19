import 'package:flutter/material.dart';
import 'package:pastry/screens/another_user_profile/user_list.dart';
import 'package:pastry/screens/my_profile/profile.dart';
import 'package:pastry/screens/orders/order_list.dart';
import 'package:pastry/screens/portfolio/portfolio.dart';

/// This is the stateful widget that the main application instantiates.
class MainScreenMobileWidget extends StatefulWidget {
  const MainScreenMobileWidget({Key? key}) : super(key: key);

  @override
  State<MainScreenMobileWidget> createState() => _MainScreenMobileWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MainScreenMobileWidgetState extends State<MainScreenMobileWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = [
    Profile(withAppBar: true,),
    Orders(withAppBar: true,),
    Portfolio(withAppBar: true,),
    UserList(withAppBar: true,)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IndexedStack(
          children: _widgetOptions,
          index: _selectedIndex,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Заказы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Портфолио',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Пользователи',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
