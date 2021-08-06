import 'package:firebase_auth/firebase_auth.dart';
import 'package:pastry/main.dart';

class AppUser {
  AppUser({
    required this.id,
    this.photoUrl,
    this.name,
    this.surname,
  });

  AppUser.fromJson(Map<String, Object?> json)
      : this(
          id: json['id']! as String,
          photoUrl: json['photo_url'] as String,
          name: json['name']! as String,
          surname: json['surname']! as String,
        );

  AppUser.fromAuthUser(User authUser)
      : this(
          id: authUser.uid,
          photoUrl: authUser.photoURL,
          name: (authUser.displayName == null ||
                  authUser.displayName!.trim().isEmpty)
              ? null
              : authUser.displayName!.split(' ')[0],
          surname: (authUser.displayName == null ||
                  authUser.displayName!.trim().isEmpty)
              ? null
              : authUser.displayName!.split(' ')[1],
        );

  final String id;
  final String? photoUrl;
  String? name;
  String? surname;
  static const String defaultPhotoUrl =
      'https://yt3.ggpht.com/a/AATXAJxgMqR_dhM4UdhhherXxKThSs3gXkKxEGIWMZpX4Q=s900-c-k-c0xffffffff-no-rj-mo';

  Map<String, Object?> toJson() {
    return {
      'photo_url': photoUrl,
      'name': name,
      'surname': surname,
    };
  }

  Future toFirestore() async {
    await appUsersRef.doc(this.id).set(this);
  }
}

final appUsersRef = firestore.collection('users').withConverter<AppUser>(
      fromFirestore: (snapshot, _) => AppUser.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );
