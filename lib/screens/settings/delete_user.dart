import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conspacesapp/components/text_field_container.dart';
import 'package:conspacesapp/screens/auth_screen.dart';
import 'package:conspacesapp/widgets/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

class DeleteUser extends StatefulWidget {
  final String userMail;

  DeleteUser(this.userMail);

  @override
  _DeleteUserState createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  var _userPassword = '';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future _tryDelete(globalKey) async {
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
      String email = widget.userMail.trim();
      String password = _userPassword.trim();

      //await sendPasswordResetEmail(email);

      final user = FirebaseAuth.instance.currentUser;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('requests')
          .where("status", isEqualTo: "accepted")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        SnackBar snackBar = SnackBar(
          content: Text(
            'Deletion failed because your account is part of an active swap.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF4845c7),
        );
        globalKey.currentState.showSnackBar(snackBar);

        return null;
      }

      try {
        //final user = FirebaseAuth.instance.currentUser;
        AuthCredential credentials =
            EmailAuthProvider.credential(email: email, password: password);
        print(user);
        UserCredential result =
            await user.reauthenticateWithCredential(credentials);
        await DatabaseService(user: user)
            .deleteuser(); // called from database class
        //await result.user.delete();
        result.user.delete();
        Navigator.popUntil(context, ModalRoute.withName("/"));

        return true;
      } catch (e) {
        print(e.toString());
        SnackBar snackBar = SnackBar(
          content: Text(
            'The password is invalid.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF4845c7),
        );
        globalKey.currentState.showSnackBar(snackBar);
        // Scaffold.of(ctx).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       'The password is invalid.',
        //     ),
        //     backgroundColor: Color(0xFF4845c7),
        //   ),
        // );
        return null;
      }

      // Navigator.of(context).pop();
    }
    setState(() {
      _isLoading = false;
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Delete Account & Data"),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 50, top: 10),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/black-logo.svg",
                    height: size.height * 0.15,
                  ),
                  SizedBox(height: size.height * 0.05),
                  Center(
                    child: Text(
                      "Deletion of your account and all data related to it is possible if you are not currently part of an active swap with another user on Conspaces. If you proceed with the deletion of your account, your account and all data related to it will be deleted. This process cannot be reversed. Feel free to contact us at conspaces@outlook.com with any questions, problems or uncertainties.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Center(
                    child: Text(
                      "\nType in your password to continue with the deletion.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        // column should only take as much space as needed (default is as much as possible)
                        //mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            //height: size.height * 0.08,
                            //height: size.height * 0.1,
                            child: TextFieldContainer(
                              child: TextFormField(
                                obscureText: true,
                                key: ValueKey('password'),
                                validator: (value) {
                                  if (value.isEmpty || value.length < 6) {
                                    return 'Please enter your password';
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
                                  hintStyle:
                                      TextStyle(fontSize: size.height * 0.014),
                                  border: InputBorder.none,
                                ),
                                onSaved: (value) {
                                  _userPassword = value;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: size.width * 0.8,
                      child: RaisedButton.icon(
                          onPressed: () {
                            _tryDelete(_scaffoldKey);
                            // print('deleting user');
                            // //deleteUser(userMail);
                            // Navigator.popUntil(context, ModalRoute.withName("/"));
                          },
                          icon: Icon(Icons.delete_forever),
                          color: const Color(0xFF4845c7),
                          label: Text('Delete Account and Data')),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
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
