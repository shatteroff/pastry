import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pastry/generated/l10n.dart';
import 'package:pastry/main.dart';
import 'package:pastry/models/user.dart';

class Profile extends StatefulWidget {
  final bool withAppBar;

  const Profile({Key? key, required this.withAppBar}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _photoUrl = AppUser.defaultPhotoUrl;
  String? _title = 'Pastry';

  @override
  void initState() {
    super.initState();
    setState(() {
      _photoUrl = _getAvatarUrl();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _title = _getDisplayName();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      children: [
        Container(
            width: 150,
            height: 150,
            child: CachedNetworkImage(
              imageUrl: _photoUrl!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/instagram.png',
                width: 20, height: 20, fit: BoxFit.cover),
            Text("https://www.instagram.com/pauline_cake/",
                style: TextStyle(
                    decoration: TextDecoration.underline, color: Colors.blue))
          ],
        ),
        ElevatedButton(
            onPressed: () async {
              List updates = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfile()));
              await auth.currentUser!.reload();
              setState(() {
                if (updates.contains('avatar')) {
                  _photoUrl = _getAvatarUrl();
                }
                if (updates.contains('name')) {
                  _title = _getDisplayName();
                }
              });
            },
            child: Text('Редактировать профиль'))
      ],
    );
    if (widget.withAppBar) {
      return Scaffold(
          appBar: widget.withAppBar
              ? AppBar(
                  title: Text(_title!),
                  actions: (auth.currentUser == null)
                      ? []
                      : [
                          IconButton(
                              onPressed: () {
                                auth.signOut();
                              },
                              icon: Icon(Icons.exit_to_app))
                        ],
                )
              : null,
          body: body);
    } else {
      return body;
    }
  }

  String? _getAvatarUrl() {
    return (auth.currentUser?.photoURL) != null
        ? auth.currentUser!.photoURL
        : AppUser.defaultPhotoUrl;
  }

  String? _getDisplayName() {
    return (auth.currentUser?.displayName == null ||
            auth.currentUser!.displayName!.isEmpty)
        ? S.of(context).appName
        : auth.currentUser!.displayName!;
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  List _updates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Редактирование профиля'),
          actions: [
            IconButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    AppUser user = AppUser.fromAuthUser(auth.currentUser!);
                    user.name = _nameController.text.trim();
                    user.surname = _surnameController.text.trim();
                    user.toFirestore();
                    auth.currentUser!
                        .updateDisplayName('${user.name} ${user.surname}');
                    _updates.add('name');
                    Navigator.pop(context, _updates);
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
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Имя'),
                  ),
                  TextFormField(
                    controller: _surnameController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Фамилия'),
                  ),
                  ElevatedButton(
                      onPressed: _uploadAvatar, child: Text('Сменить аватар'))
                ],
              ),
            )));
  }

  _uploadAvatar() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        PlatformFile file = result.files.first;
        firebase_storage.UploadTask? task;
        String storagePath = '${auth.currentUser!.uid}/avatar';

        if (isMobileDevice) {
          task = storage.ref(storagePath).putFile(File(file.path!));
        } else {
          Uint8List? fileBytes = file.bytes;
          task = storage.ref(storagePath).putData(fileBytes!);
        }
        if (task != null) {
          task.snapshotEvents
              .listen((firebase_storage.TaskSnapshot snapshot) async {
            print('Task state: ${snapshot.state}');
            print(
                'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
            if (snapshot.state == firebase_storage.TaskState.success) {
              String photoUrl = await firebase_storage.FirebaseStorage.instance
                  .ref('${auth.currentUser!.uid}/avatar')
                  .getDownloadURL();
              auth.currentUser!.updatePhotoURL(photoUrl);
              _updates.add('avatar');
            }
          });
        }
      }
    } on PlatformException catch (e) {
      print('Unsupported Operation ' + e.toString());
    } on FirebaseException catch (e) {
      print('Unsupported Operation ' + e.toString());
    }
  }
}
