import 'package:flutter/material.dart';
import 'package:pastry/screens/another_user_profile/user_list.dart';
import 'package:pastry/screens/my_profile/profile.dart';
import 'package:pastry/screens/orders/order_list.dart';
import 'package:pastry/screens/portfolio/portfolio.dart';

class MainScreenWebWidget extends StatefulWidget {
  const MainScreenWebWidget({Key? key}) : super(key: key);

  @override
  _MainScreenWebWidgetState createState() => _MainScreenWebWidgetState();
}

class _MainScreenWebWidgetState extends State<MainScreenWebWidget> {
  List<String> _btns = ['Профиль', 'Заказы', 'Портфолио', 'Пользователи'];
  List<Icon> _icons = [
    Icon(Icons.home),
    Icon(Icons.business),
    Icon(Icons.school),
    Icon(Icons.supervised_user_circle)
  ];
  Widget _mainWidget = Profile(withAppBar: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pastry')),
      body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              child: ListView(
                children: _getMenu(),
              ),
            ),
            Container(width: 600, child: Card(child: _mainWidget))
          ]),
    );
  }

  List<ListTile> _getMenu() {
    List<ListTile> tiles = [];
    for (var i = 0; i < _btns.length; i++) {
      tiles.add(ListTile(
        minLeadingWidth: 0,
        leading: _icons[i],
        title: Text(_btns[i]),
        enabled: true,
        onTap: () {
          print(i);
          Widget? selectedWidget;
          switch (i) {
            case 0:
              selectedWidget = Profile(withAppBar: false);
              break;
            case 1:
              selectedWidget = Orders(withAppBar: false);
              break;
            case 2:
              selectedWidget = Portfolio(withAppBar: false);
              break;
            case 3:
              selectedWidget = UserList(withAppBar: false);
              break;
          }
          setState(() {
            print(selectedWidget);
            _mainWidget = selectedWidget!;
          });
        },
      ));
    }
    return tiles;
  }
}
