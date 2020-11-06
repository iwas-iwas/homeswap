import 'package:flutter/material.dart';
import '../Signup/components/body.dart';
import 'package:flutter/material.dart';
import '../Login/login_screen.dart';
import '../Signup/components/background.dart';
import '../Signup/components/or_divider.dart';
import '../Signup/components/social_icon.dart';
import '../../components/already_have_an_account_acheck.dart';
import '../../components/rounded_button.dart';
import '../../components/rounded_input_field.dart';
import '../../components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import '../../components/text_field_container.dart';
import '../../constants.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    //File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  // switch between login and signup mode
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';

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
        _isLogin = false,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "SIGNUP",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.03),
                SvgPicture.asset(
                  "assets/icons/black-logo.svg",
                  height: size.height * 0.20,
                ),
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
                      hintText: "Your Email",
                      border: InputBorder.none,
                    ),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                ),
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
                      hintText: "Your Username",
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
                      hintText: "Your Password",
                      border: InputBorder.none,
                    ),
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                ),
                // RoundedPasswordField(
                //   onChanged: (value) {},
                // ),
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
                          "SIGNUP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                // RoundedButton(
                //   text: "SIGNUP",
                //   press: _trySubmit,
                // ),
                SizedBox(height: size.height * 0.03),
                AlreadyHaveAnAccountCheck(
                  login: false,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ),
                    );
                  },
                ),
                // OrDivider(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     SocalIcon(
                //       iconSrc: "assets/icons/facebook.svg",
                //       press: () {},
                //     ),
                //     SocalIcon(
                //       iconSrc: "assets/icons/twitter.svg",
                //       press: () {},
                //     ),
                //     SocalIcon(
                //       iconSrc: "assets/icons/google-plus.svg",
                //       press: () {},
                //     ),
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
