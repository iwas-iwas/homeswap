// import 'package:flutter/material.dart';
// import './components/body.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// //import '../widgets/auth/auth_form.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';

// class WelcomeScreen extends StatefulWidget {
//   @override
//   _WelcomeScreenState createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final _auth = FirebaseAuth.instance;
//   final FirebaseMessaging _messaging = FirebaseMessaging();
//   var _isLoading = false;

//   void _submitAuthForm(
//     String email,
//     String password,
//     String username,
//     //File image,
//     bool isLogin,
//     BuildContext ctx,
//   ) async {
//     //AuthResult authResult;
//     UserCredential authResult;

//     try {
//       setState(() {
//         print('_isLoading');
//         print(_isLoading);
//         _isLoading = true;
//         print('_isLoading after');
//         print(_isLoading);
//       });
//       if (isLogin) {
//         authResult = await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//       } else {
//         authResult = await _auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );

//         // UPLOAD IMAGE

//         // final ref returns reference to the image
//         // final ref = FirebaseStorage.instance
//         //     .ref()
//         //     .child('user_images')
//         //     .child(authResult.user.uid + '.jpg');

//         // // here we get the image reference (url) from the image file and set it in the user document
//         // await ref.putFile(image).onComplete;

//         // final url = await ref.getDownloadURL();
//         String token = await _messaging.getToken();

//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(authResult.user.uid)
//             .set({
//           'username': username,
//           'email': email,
//           'token': token,
//           'image_url': null,
//         });
//       }
//     } on PlatformException catch (err) {
//       var message = 'An error occurred, pelase check your credentials!';

//       if (err.message != null) {
//         message = err.message;
//       }

//       Scaffold.of(ctx).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Theme.of(ctx).errorColor,
//         ),
//       );
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (err) {
//       print(err);
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: WelcomeScreen(_submitAuthForm, _isLoading),
//     );
//   }
// }
