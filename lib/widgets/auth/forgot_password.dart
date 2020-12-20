import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../screens/Signup/components/background.dart';
import 'package:flutter_svg/svg.dart';
import '../../components/text_field_container.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword(
    this.scaffoldKey,
  );

  GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  //bool _showForgotPassword = false;
  final _formKey = GlobalKey<FormState>();
  // switch between login and signup mode
  //var _isLogin = true;
  var _isLoading = false;
  var _userEmail = '';
  // var _userName = '';
  // var _userPassword = '';
  //File _userImageFile;

  // void _pickedImage(File image) {
  //   _userImageFile = image;
  // }

  final _auth = FirebaseAuth.instance;

  Future sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future _tryReset(globalKey) async {
    setState(() {
      _isLoading = true;
    });

    final isValid = _formKey.currentState.validate();
    // makes sure the keyboard closes
    FocusScope.of(context).unfocus();

    // if all validators return null
    if (isValid) {
      // trigger onsaved of all form fields
      _formKey.currentState.save();
      // Use those values to send auth request...
      String email = _userEmail.trim();

      try {
        await sendPasswordResetEmail(email);
      } catch (e) {
        print("lol " + e.message.toString());
        SnackBar snackBar = SnackBar(
            content: Text(
              'Your submissions has been received. If we have an account matching your email address, you will receive an email with a link to reset your password.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF4845c7),
            duration: const Duration(seconds: 10));
        globalKey.currentState.showSnackBar(snackBar);
        Navigator.of(context).pop();
        // globalKey.currentState.showSnackBar(SnackBar(
        //   content: Text(
        //     'The email is invalid.',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   backgroundColor: Color(0xFF4845c7),
        // ));
        // Scaffold.of(context).showSnackBar(SnackBar(
        //   content: Text(
        //     'The email is invalid.',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   backgroundColor: Color(0xFF4845c7),
        // ));
        //Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });

        return null;
      }

      SnackBar snackBar = SnackBar(
          content: Text(
            'Your submissions has been received. If we have an account matching your email address, you will receive an email with a link to reset your password.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF4845c7),
          duration: const Duration(seconds: 10));
      globalKey.currentState.showSnackBar(snackBar);
      Navigator.of(context).pop();
    }
    setState(() {
      _isLoading = false;
    });
  }

  //final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      //key: _scaffoldKey,
      body: Background(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                // column should only take as much space as needed (default is as much as possible)
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SvgPicture.asset(
                    "assets/icons/black-logo.svg",
                    height: size.height * 0.20,
                  ),
                  SizedBox(height: size.height * 0.03),
                  //if (!_isLogin) UserImagePicker(_pickedImage),
                  TextFieldContainer(
                    child: TextFormField(
                      key: ValueKey('email'),
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email adress';
                        }
                        // all good
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      //onChanged: onChanged,
                      cursorColor: kPrimaryColor,
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.person,
                          color: kPrimaryColor,
                        ),
                        hintText: "Email",
                        border: InputBorder.none,
                      ),
                      onSaved: (value) {
                        _userEmail = value;
                      },
                    ),
                  ),

                  if (_isLoading) CircularProgressIndicator(),
                  if (!_isLoading)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      width: size.width * 0.8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(29),
                        child: FlatButton(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
                          color: kPrimaryColor,
                          onPressed: () =>
                              //_tryReset(widget.scaffoldKey, _scaffoldKey),
                              _tryReset(widget.scaffoldKey),
                          child: Text(
                            'Reset Password',
                          ),
                        ),
                      ),
                    ),
                  if (!_isLoading)
                    CupertinoButton(
                      //minSize: double.minPositive,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Return to Sign In',
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
