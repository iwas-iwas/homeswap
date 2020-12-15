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

const kPrimaryColor = Color(0xFF4845c7);
const kPrimaryLightColor = Color(0xFFe2e2f6);

const kColorPrimaryLight = Color(0xff424B67);
const kColorPrimaryDark = Color(0xff21293E);
const kColorAccent = Colors.blue;
const kColorText = Color(0xffDBEDF3);

const kColorPrimary = Colors.white;
