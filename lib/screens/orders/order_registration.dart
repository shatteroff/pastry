import 'package:flutter/material.dart';
import 'package:pastry/generated/l10n.dart';
import 'package:pastry/main.dart';
import 'package:pastry/models/orders.dart';

class OrderRegistration extends StatefulWidget {
  const OrderRegistration({Key? key}) : super(key: key);

  @override
  _OrderRegistrationState createState() => _OrderRegistrationState();
}

class _OrderRegistrationState extends State<OrderRegistration> {
  final Map<String, String> _testUsers = {
    'test@test.net': 'dELZm3HgyHR47h82tUSEq4Uuzn53',
    'test2@test.net': 'D3ONqFLq1pQ7h6FRjde70x7EQW63'
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool _isCommon = true;

  @override
  Widget build(BuildContext context) {
    _testUsers.remove(auth.currentUser!.email);
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).appName),
          actions: [
            IconButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String? executor;
                    if (!_isCommon) {
                      executor = _testUsers.values.first;
                    }
                    Order order = Order(
                        executor: executor,
                        customer: auth.currentUser!.uid,
                        insertDt: DateTime.now(),
                        product: _productController.text,
                        finishDt: DateTime.now().add(Duration(
                            days: int.parse(_durationController.text))));
                    await ordersRef.add(order);
                    Navigator.pop(context, order);
                  }
                },
                icon: Icon(Icons.send))
          ],
        ),
        body: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _productController,
                    decoration: InputDecoration(labelText: 'Тип продукта'),
                  ),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Длительность приготовления'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Поле не может быть пустым';
                      } else {
                        try {
                          int.parse(value.trim());
                        } on FormatException catch (e) {
                          return 'Введите корректное число';
                        }
                        return null;
                      }
                    },
                  ),
                  CheckboxListTile(
                      title: Text('Общий заказ'),
                      value: _isCommon,
                      onChanged: (value) {
                        setState(() {
                          _isCommon = value!;
                        });
                      })
                ],
              ),
            )));
  }
}
