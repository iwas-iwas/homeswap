import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conspacesapp/constants.dart';
import 'package:conspacesapp/widgets/storage_service.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart' as User; //
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import './storage_service.dart';

class DatabaseService {
  final user = FirebaseAuth.instance.currentUser;

  Future<User.User> getUser(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    //return User.fromDoc(userDoc);
    return User.User.fromDoc(userDoc);
  }
}
