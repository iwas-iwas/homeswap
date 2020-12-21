//import 'package:conspacesapp/screens/Welcome/welcome_screen.dart';
import 'package:conspacesapp/widgets/auth/auth_form_anon.dart';
// import 'package:conspacesapp/widgets/database_service.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/auth/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';

// import 'Welcome/components/body.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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

      await Purchases.identify(currentUser.uid);
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

        await Purchases.identify(authResult.user.uid);
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

        await Purchases.identify(authResult.user.uid);
      }
    } on PlatformException catch (err) {
      var message = 'You have entered an invalid email or password.';
      // print('im here');
      // print(err);
      // print(message);

      if (err.message != null) {
        message = err.message;
        print("platformexception: " + message);
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Color(0xFF4845c7),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      // } on FirebaseAuthException catch (e) {
      //   // weak password wird nur getrhowd bei <6 letters, was sowieso im backend abgedeckt ist.
      //   // if (e.code == 'weak-password') {
      //   //   print('The password provided is too weak bro.');
      //   //   Scaffold.of(ctx).showSnackBar(
      //   //     SnackBar(
      //   //       content: Text('Your password is too weak.'),
      //   //       backgroundColor: Color(0xFF4845c7),
      //   //     ),
      //   //   );
      //   // }
      //   if (e.code == 'email-already-in-use') {
      //     Scaffold.of(ctx).showSnackBar(
      //       SnackBar(
      //         content:
      //             Text("The email address is already in use by another account."),
      //         backgroundColor: Color(0xFF4845c7),
      //       ),
      //     );
      //     print('The account already exists for that email bro.');
      //     setState(() {
      //       _isLoading = false;
      //     });
      //   }
    } catch (err) {
      if (err.code == 'email-already-in-use') {
        Scaffold.of(ctx).showSnackBar(
          SnackBar(
            content:
                Text("The email address is already in use by another account."),
            backgroundColor: Color(0xFF4845c7),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } else if ((err.code == 'too-many-requests')) {
        Scaffold.of(ctx).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(
                'Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.'),
            backgroundColor: Color(0xFF4845c7),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } else {
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
