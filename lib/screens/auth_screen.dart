import 'package:conspacesapp/screens/Welcome/welcome_screen.dart';
import 'package:conspacesapp/widgets/auth/auth_form_anon.dart';
import 'package:conspacesapp/widgets/database_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/auth/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'Welcome/components/body.dart';

class AuthScreen extends StatefulWidget {
  bool isAnon;

  AuthScreen({this.isAnon = false});
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  var _isLoading = false;

  Future sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // Future deleteUser(String email, String password) async {
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     AuthCredential credentials =
  //         EmailAuthProvider.credential(email: email, password: password);
  //     print(user);
  //     UserCredential result =
  //         await user.reauthenticateWithCredential(credentials);
  //     await DatabaseService(user: user)
  //         .deleteuser(); // called from database class
  //     await result.user.delete();
  //     return true;
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // Create Anonymous User
  Future signInAnonymously() {
    setState(() {
      _isLoading = true;
    });
    // return _auth.signInAnonymously();
    _auth.signInAnonymously();
    setState(() {
      _isLoading = false;
    });
  }

  Future convertUserWithEmail(
    String email,
    String password,
    String username,
    //File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;

      final crediential =
          EmailAuthProvider.credential(email: email, password: password);
      await currentUser.linkWithCredential(crediential);

      String token = await _messaging.getToken();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'username': username,
        'email': email,
        'token': token,
        'image_url': null,
      });
    } on PlatformException catch (err) {
      var message = 'An error occurred, pelase check your credentials!';

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitAuthForm(
    String email,
    String password,
    String username,
    //File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    //AuthResult authResult;
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // UPLOAD IMAGE

        // final ref returns reference to the image
        // final ref = FirebaseStorage.instance
        //     .ref()
        //     .child('user_images')
        //     .child(authResult.user.uid + '.jpg');

        // // here we get the image reference (url) from the image file and set it in the user document
        // await ref.putFile(image).onComplete;

        // final url = await ref.getDownloadURL();
        String token = await _messaging.getToken();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'email': email,
          'token': token,
          'image_url': null,
        });
      }
    } on PlatformException catch (err) {
      var message = 'You have entered an invalid email or password.';
      // print('im here');
      // print(err);
      // print(message);

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text('You have entered an invalid email or password.'),
          backgroundColor: Color(0xFF4845c7),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (widget.isAnon) {
      return Scaffold(
        //key: _scaffoldKey,
        //backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        //body: AuthForm(_submitAuthForm, _isLoading, _scaffoldKey),
        body: AuthFormAnon(
            _submitAuthForm, _isLoading, _scaffoldKey, convertUserWithEmail),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      //backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      //body: AuthForm(_submitAuthForm, _isLoading, _scaffoldKey),
      body: AuthForm(
          _submitAuthForm, _isLoading, _scaffoldKey, signInAnonymously),
    );
  }
}
