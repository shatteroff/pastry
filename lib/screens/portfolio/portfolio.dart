import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({Key? key}) : super(key: key);

  @override
  _PortfolioState createState() {
    return _PortfolioState();
  }
}

class _PortfolioState extends State<Portfolio>
    with AutomaticKeepAliveClientMixin<Portfolio> {
  Widget _imageGrid = Center();

  @override
  void initState() {
    super.initState();
    _updateGrid();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Pastry'),
          actions: [
            IconButton(onPressed: _openFileExplorer, icon: Icon(Icons.add))
          ],
        ),
        body: RefreshIndicator(onRefresh: _updateGrid, child: _imageGrid));
  }

  _openFileExplorer() async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: true);

      if (result != null) {
        result.files.forEach((element) {
          String fileName = element.name;
          firebase_storage.UploadTask? task;
          String storagePath = '${auth.currentUser!.uid}/$fileName';
          // Upload file

          if (isMobileDevice) {
            task = storage.ref(storagePath).putFile(File(element.path!));
          } else {
            Uint8List? fileBytes = element.bytes;
            task = storage.ref(storagePath).putData(fileBytes!);
          }
          if (task != null) {
            task.snapshotEvents
                .listen((firebase_storage.TaskSnapshot snapshot) {
              print('Task state: ${snapshot.state}');
              print(
                  'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
            });
          }
        });
      }
    } on PlatformException catch (e) {
      print('Unsupported Operation ' + e.toString());
    } on FirebaseException catch (e) {
      print('Unsupported Operation ' + e.toString());
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  Future<void> _updateGrid() async {
    _getUserImages().then((value) => setState(() {
          print('setState');
          print(value);
          _imageGrid = GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5),
              itemCount: value.length,
              itemBuilder: (BuildContext ctx, index) {
                return value[index % value.length];
              });
        }));
  }

  Future<List<CachedNetworkImage>> _getUserImages() async {
    print('getUserImages');
    firebase_storage.ListResult result =
        await storage.ref(auth.currentUser!.uid).listAll();
    List<firebase_storage.Reference> images = result.items;
    List<CachedNetworkImage> imageViews = [];
    for (int i = 0; i < images.length; i++) {
      await images[i]
          .getDownloadURL()
          .then((value) => imageViews.add(CachedNetworkImage(
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                imageUrl: value,
                errorWidget: (context, url, error) => Icon(Icons.error),
              )));
    }
    return imageViews;
  }
}

// Future<Image> getImageFromStorage(int index) async {
//   List<firebase_storage.Reference> images = await listExample();
//   return Image.network(images[index].getDownloadURL().toString());
// }

// Future<Widget> getImageGrid() async {
//   List<CachedNetworkImage> images = await getUserImages();
//
//   return Expanded(
//       child: GridView.builder(
//           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//               maxCrossAxisExtent: 150,
//               crossAxisSpacing: 20,
//               mainAxisSpacing: 20),
//           itemCount: 5,
//           itemBuilder: (BuildContext ctx, index) {
//             return images[index];
//           }));
// }

// Future<List<firebase_storage.Reference>> listExample() async {
//   firebase_storage.ListResult result =
//       await storage.ref(auth.currentUser!.uid).listAll();
//   return result.items;
// }
