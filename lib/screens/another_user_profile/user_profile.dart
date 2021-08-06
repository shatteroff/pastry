import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pastry/main.dart';
import 'package:pastry/models/user.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserProfile extends StatefulWidget {
  final AppUser user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<CachedNetworkImage> _portfolio = [];

  @override
  void initState() {
    super.initState();
    _getUserImages().then((value) => setState(() {
          _portfolio = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.user.name} ${widget.user.surname}'),
        ),
        body: Column(
          children: [
            Container(
                width: 150,
                height: 150,
                child: CachedNetworkImage(
                  imageUrl: (widget.user.photoUrl == null)
                      ? AppUser.defaultPhotoUrl
                      : widget.user.photoUrl!,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
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
                Text(
                    "https://www.instagram.com/${widget.user.name!.toLowerCase()}_${widget.user.surname!.toLowerCase()}/",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue))
              ],
            ),
            Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  itemCount: _portfolio.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return _portfolio[index % _portfolio.length];
                  }),
            )
          ],
        ));
  }

  Future<List<CachedNetworkImage>> _getUserImages() async {
    print('getUserImages');
    firebase_storage.ListResult result =
        await storage.ref(widget.user.id).listAll();
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
