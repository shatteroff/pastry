import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pastry/generated/l10n.dart';
import 'package:pastry/main.dart';
import 'package:pastry/models/orders.dart';
import 'package:pastry/models/user.dart';

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
  final TextEditingController _typeAheadController = TextEditingController();
  List<AppUser> _users = [];
  bool _isCommon = true;
  String? _executor;

  @override
  void initState() {
    super.initState();
    _getUsers().then((value) => setState(() {
          _users = value;
        }));
  }

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
                    this._formKey.currentState!.save();
                    // String? executor;
                    // if (!_isCommon) {
                    //   executor = _testUsers.values.first;
                    // }
                    Order order = Order(
                        executor: _executor,
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
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                        controller: this._typeAheadController,
                        decoration: InputDecoration(labelText: 'Исполнитель')),
                    suggestionsCallback: (pattern) {
                      return _getUsersFromPattern(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      suggestion = suggestion as AppUser;
                      return ListTile(
                        title: Text('${suggestion.name} ${suggestion.surname}'),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) {
                      suggestion = suggestion as AppUser;
                      this._typeAheadController.text = suggestion.fullName!;
                    },
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return 'Please select a city';
                    //   }
                    // },
                    onSaved: (value) => _setExecutor(value!),
                  ),
                  // CheckboxListTile(
                  //     title: Text('Общий заказ'),
                  //     value: _isCommon,
                  //     onChanged: (value) {
                  //       setState(() {
                  //         _isCommon = value!;
                  //       });
                  //     })
                ],
              ),
            )));
  }

  Future<List<AppUser>> _getUsers() async {
    List<AppUser> users = [];
    CollectionReference userCollection = firestore.collection('users');
    QuerySnapshot snapshot = await userCollection.get();
    // QuerySnapshot snapshot = await appUsersRef.get();
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) {
        print(doc.data());
        if (doc.id != auth.currentUser!.uid) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data.addAll({'id': doc.id});
          users.add(AppUser.fromJson(data));
        }
      });
    }
    return users;
  }

  List<AppUser> _getUsersFromPattern(String pattern) {
    List<AppUser> foundUsers = [];
    pattern = pattern.toLowerCase();
    if (_users.isNotEmpty) {
      _users.forEach((element) {
        if (element.fullName!.toLowerCase().contains(RegExp(pattern))) {
          foundUsers.add(element);
        }
      });
    }
    return foundUsers;
  }

  _setExecutor(String fullName) {
    if (_users.isNotEmpty) {
      _users.forEach((element) {
        if (element.fullName == fullName) {
          _executor = element.id;
        }
      });
    }
  }
}
