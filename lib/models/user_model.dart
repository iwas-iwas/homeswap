import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String imageUrl;
  final String token;

  User({this.id, this.username, this.email, this.imageUrl, this.token});

  // return a user object
  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
        id: doc.id,
        username: doc.data()['username'] ?? "",
        email: doc.data()['email'] ?? "",
        imageUrl: doc.data()['image_url'] ?? "",
        token: doc.data()['token'] ?? "");
  }
}
