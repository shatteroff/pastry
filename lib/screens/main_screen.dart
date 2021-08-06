import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pastry/main.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _imageGrid = Expanded(child:Center(child: CircularProgressIndicator()));

  _MainScreenState() {
    getUserImages().then((value) => setState(() {
          print('setState');
          print(value);
          _imageGrid = Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: 50,
                  itemBuilder: (BuildContext ctx, index) {
                    return value[index % value.length];
                  }));
        }));
  }

  @override
  Widget build(BuildContext context) {
    String? photoUrl = (auth.currentUser?.photoURL) != null
        ? auth.currentUser!.photoURL
        : 'https://yt3.ggpht.com/a/AATXAJxgMqR_dhM4UdhhherXxKThSs3gXkKxEGIWMZpX4Q=s900-c-k-c0xffffffff-no-rj-mo';
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: (auth.currentUser?.photoURL) != null
                      ? NetworkImage(photoUrl!)
                      : Image.asset('images/instagram.png').image,
                  fit: BoxFit.cover)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/instagram.png',
                width: 20, height: 20, fit: BoxFit.cover),
            Text("https://www.instagram.com/pauline_cake/",
                style: TextStyle(
                    decoration: TextDecoration.underline, color: Colors.blue))
          ],
        ),
        ElevatedButton(
            onPressed: _openFileExplorer, child: Text("upload image")),
        _imageGrid
      ],
    );
  }

  _openFileExplorer() async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: true);

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = result.files.first.name;

        UploadTask? task;
        String storagePath = '${auth.currentUser!.uid}/$fileName';
        // Upload file
        if (isMobileDevice) {
          task = storage
              .ref(storagePath)
              .putFile(File(result.files.first.path!));
        } else {
          task = storage.ref(storagePath).putData(fileBytes!);
        }
        if (task!=null){
          task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
            print('Task state: ${snapshot.state}');
            print(
                'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
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

Future<Image> getImageFromStorage(int index) async {
  List<firebase_storage.Reference> images = await listExample();
  return Image.network(images[index].getDownloadURL().toString());
}

Future<List<Image>> getUserImages() async {
  print('getUserImages');
  List<firebase_storage.Reference> images = await listExample();
  List<Image> imageViews = [];
  for (int i = 0; i < images.length; i++) {
    await images[i]
        .getDownloadURL()
        .then((value) => imageViews.add(Image.network(value)));
  }
  ;
  // return Center(child: CircularProgressIndicator());
  // print(imageViews);
  return imageViews;
}

// Future<List<String>> getUrl(List<firebase_storage.Reference> refs) async {
//   for (int i=0;)
// }

Future<Widget> getImageGrid() async {
  List<Image> images = await getUserImages();

  return Expanded(
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          itemCount: 5,
          itemBuilder: (BuildContext ctx, index) {
            return images[index];
          }));
}

Future<List<firebase_storage.Reference>> listExample() async {
  firebase_storage.ListResult result =
      await storage.ref(auth.currentUser!.uid).listAll();

  // result.items.forEach((firebase_storage.Reference ref) {
  //   print('Found file: $ref');
  // });
  //
  // result.prefixes.forEach((firebase_storage.Reference ref) {
  //   print('Found directory: $ref');
  // });
  return result.items;
}
