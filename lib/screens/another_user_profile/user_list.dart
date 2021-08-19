import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pastry/main.dart';
import 'package:pastry/models/user.dart';
import 'package:pastry/screens/another_user_profile/user_profile.dart';

class UserList extends StatefulWidget {
  final bool withAppBar;

  const UserList({Key? key, required this.withAppBar}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<AppUser>? _users;

  @override
  void initState() {
    super.initState();
    _updateList();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      children: [
        Expanded(
          child: RefreshIndicator(
              onRefresh: _updateList, child: _getUsersListView(_users)),
        )
      ],
    );
    if (widget.withAppBar) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Users'),
          ),
          body: body);
    } else {
      return body;
    }
  }

  Future _updateList() async {
    _getUsers().then((value) => setState(() {
          _users = value;
        }));
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

  _getUsersListView(List<AppUser>? users) {
    Widget listView = Center(child: Text('Данный список пуст'));
    if (users != null && users.isNotEmpty) {
      listView = ListView.builder(
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: Container(
                  height: 80,
                  child: Card(
                    child: Center(
                        child: Text(
                            '${users[index].name} ${users[index].surname}')),
                  )),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserProfile(user: _users![index])));
              },
            );
          });
    }
    return listView;
  }
}
