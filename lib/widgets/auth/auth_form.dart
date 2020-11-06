import 'package:conspacesapp/widgets/auth/forgot_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import '../pickers/user_image_picker.dart';
// import 'dart:io';
import '../../constants.dart';
// import '../../screens/Signup/components/body.dart';
import 'package:flutter/material.dart';
// import '../../screens/Login/login_screen.dart';
import '../../screens/Signup/components/background.dart';
// import '../../screens/Signup/components/or_divider.dart';
// import '../../screens/Signup/components/social_icon.dart';
// import '../../components/already_have_an_account_acheck.dart';
// import '../../components/rounded_button.dart';
// import '../../components/rounded_input_field.dart';
// import '../../components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import '../../components/text_field_container.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
    this.scaffoldKey,
  );

  final bool isLoading;
  GlobalKey<ScaffoldState> scaffoldKey;
  final void Function(
    String email,
    String password,
    String userName,
    //File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  //bool _showForgotPassword = false;
  final _formKey = GlobalKey<FormState>();
  // switch between login and signup mode
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  //File _userImageFile;

  // void _pickedImage(File image) {
  //   _userImageFile = image;
  // }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    // makes sure the keyboard closes
    FocusScope.of(context).unfocus();

    // dont start to submit the form if no image has been picked
    // if (_userImageFile == null && !_isLogin) {
    //   Scaffold.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Please pick an image.'),
    //       backgroundColor: Theme.of(context).errorColor,
    //     ),
    //   );
    //   return;
    // }

    // if all validators return null
    if (isValid) {
      // trigger onsaved of all form fields
      _formKey.currentState.save();
      // Use those values to send auth request...
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        //_userImageFile,
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
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
                  _isLogin ? 'Sign In' : 'Sign Up',
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
                if (!_isLogin) // only show username is signup mode, not in login
                  TextFieldContainer(
                    child: TextFormField(
                      key: ValueKey('username'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters';
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
                        hintText: "Username",
                        border: InputBorder.none,
                      ),
                      onSaved: (value) {
                        _userName = value;
                      },
                    ),
                  ),
                TextFieldContainer(
                  child: TextFormField(
                    obscureText: true,
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be atleast 7 characters long';
                      }
                      // all good
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    //onChanged: onChanged,
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      hintText: "Password",
                      border: InputBorder.none,
                    ),
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                ),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: size.width * 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(29),
                      child: FlatButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        color: kPrimaryColor,
                        onPressed: _trySubmit,
                        child: Text(
                          _isLogin ? 'Login' : 'Signup',
                        ),
                      ),
                    ),
                  ),
                if (_isLogin && !widget.isLoading)
                  CupertinoButton(
                    minSize: double.minPositive,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ForgotPassword(widget.scaffoldKey),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  ),
                //if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  CupertinoButton(
                    //minSize: double.minPositive,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Create new account'
                          : 'I already have an account',
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  ),
                if (!_isLogin)
                  Text(
                    'By signing up on Conspaces, you agree to our Terms & Conditions and Privacy Policy',
                    style: TextStyle(color: kPrimaryColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
