import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pastry/main.dart';
import 'package:pastry/models/orders.dart';
import 'package:pastry/screens/orders/order_registration.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final _items = ['Входящие', 'Исходяшие', 'Общие'];
  Widget _listView = Center(child: CircularProgressIndicator());
  List<Order>? _orders;
  int _itemNum = 0;

  @override
  void initState() {
    super.initState();
    _updateList();
  }

  @override
  Widget build(BuildContext context) {
    // _getOrdersViaOrders().then((value) => setState(() {
    //       _orders = value;
    //     }));
    return Scaffold(
        appBar: AppBar(
          title: Text('Pastry'),
          actions: [
            IconButton(
                onPressed: () async {
                  Order order = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderRegistration()));
                  if (_itemNum == 1) {
                    List<Order> orders = [order];
                    if (_orders != null && _orders!.isNotEmpty) {
                      orders.addAll(_orders!);
                    }
                    setState(() {
                      // _listView = Center(child: Text('Success'));
                      _orders = orders;
                    });
                  }
                },
                icon: Icon(Icons.add))
          ],
        ),
        body: Column(
          children: [
            DropdownButton<String>(
              value: _items[_itemNum],
              isExpanded: true,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _itemNum = _items.indexOf(newValue!);
                });
                _getOrdersViaOrders().then((value) => setState(() {
                      _orders = value;
                    }));
              },
              items: _items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value)),
                );
              }).toList(),
            ),
            Expanded(
              child: RefreshIndicator(
                  onRefresh: _updateList, child: getOrdersListView(_orders)),
            )
          ],
        ));
  }

  Future _updateList() async {
    _getOrdersViaOrders().then((value) => setState(() {
          _orders = value;
        }));
  }

  Future<List<Order>> _getOrdersViaUser() async {
    List<Order> orders = [];
    DocumentReference userDocRef =
        firestore.collection('users').doc(auth.currentUser!.uid);
    DocumentSnapshot snapshot = await userDocRef.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List ordersRefs = data['incoming_orders'];
      if (ordersRefs != null && ordersRefs.isNotEmpty) {
        for (int i = 0; i < ordersRefs.length; i++) {
          var orderJson =
              await ordersRefs[i].get().then((value) => value.data());
          orders.add(Order.fromJson(orderJson as Map<String, dynamic>));
        }
      }
    }
    return orders;
  }

  Future<List<Order>> _getOrdersViaOrders() async {
    List<Order> orders = [];
    CollectionReference orderRef = firestore.collection('orders');
    Query? query;
    // QuerySnapshot snapshot = await firestore
    //     .collection('orders')
    //     .where('executor', isEqualTo: auth.currentUser!.uid)
    //     .get();
    // String? field, value;
    switch (_itemNum) {
      case 0:
        query = orderRef.where('executor', isEqualTo: auth.currentUser!.uid);
        break;
      case 1:
        query = orderRef.where('customer', isEqualTo: auth.currentUser!.uid);
        break;
      case 2:
        query = orderRef
            .where('executor', isNull: true)
            .where('customer', isNotEqualTo: auth.currentUser!.uid)
            .orderBy('customer');
        break;
    }
    QuerySnapshot snapshot =
        await query!.orderBy('insert_dt', descending: true).get();
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) {
        print(doc.data());
        orders.add(Order.fromJson(doc.data() as Map<String, dynamic>));
      });
    }
    return orders;
  }
}

Widget getOrdersListView(List<Order>? orders) {
  Widget listView = Center(child: Text('Данный список пуст'));
  if (orders != null && orders.isNotEmpty) {
    listView = ListView.builder(
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              child: Card(
            child: Column(children: [
              Text(orders[index].product),
              Text(orders[index].insertDt.toLocal().toString()),
              Text(orders[index].finishDt.toLocal().toString())
            ]),
          ));
        });
  }
  return listView;
}
