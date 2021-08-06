import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pastry/models/user.dart';

class Order {
  Order({
    required this.executor,
    required this.customer,
    required this.insertDt,
    required this.product,
    required this.finishDt,
  });

  Order.fromJson(Map<String, Object?> json)
      : this(
          customer: json['customer'] as String,
          executor: json['executor'] as String,
          product: json['product'] as String,
          insertDt: (json['insert_dt'] as Timestamp).toDate(),
          finishDt: (json['finish_dt'] as Timestamp).toDate(),
        );

  final String product;
  final String customer;
  final String? executor;
  // final DocumentReference<Map<String,dynamic>> executor;
  final DateTime insertDt;
  final DateTime finishDt;

  Map<String, Object?> toJson() {
    return {
      'customer': customer,
      'executor': executor,
      'product': product,
      'insert_dt': insertDt,
      'finish_dt': finishDt
    };
  }
}

final ordersRef = FirebaseFirestore.instance.collection('orders').withConverter<Order>(
  fromFirestore: (snapshot, _) => Order.fromJson(snapshot.data()!),
  toFirestore: (order, _) => order.toJson(),
);
