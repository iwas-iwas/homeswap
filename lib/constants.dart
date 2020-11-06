import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;
final usersRef = _db.collection('users');
final chatsRef = _db.collection('chats');

final FirebaseStorage _storage = FirebaseStorage.instance;
final storageRef = _storage.ref();
final DateFormat timeFormat = DateFormat('E, h:mm a');

const kPrimaryColor = Color(0xFF3532a7);
const kPrimaryLightColor = Color(0xFFe2e2f6);
