import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  var user;

  DatabaseService({this.user});

  Future deleteuser() async {
    QuerySnapshot userPropertiesQuery = await FirebaseFirestore.instance
        .collection('properties')
        .where('userId', isEqualTo: user.uid)
        .get();

    userPropertiesQuery.docs.forEach((userProperty) {
      userProperty.reference.delete();
    });

    return user.delete();
  }
}
