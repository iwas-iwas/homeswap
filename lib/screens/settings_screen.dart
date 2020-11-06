import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import './language_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  var _userName;
  var _userImage;
  var _userEmail;
  File _storedImage;

  void initState() {
    super.initState();
    _getUserData();
  }

  //TOOD: setState in _takePicture is not really working. The rebuild is not triggered / picture is not updated.
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
      //source: ImageSource.camera,
      source: ImageSource.camera,
      maxWidth: 600,
    );

    // grab the curren user
    final user = FirebaseAuth.instance.currentUser;

    // Get Image Url
    final ref = FirebaseStorage.instance
        .ref()
        .child('property_images')
        .child(user.uid + Timestamp.now().toString() + '.jpg');

    // here we get the image reference (url) from the image file and set it in the user document
    await ref.putFile(File(imageFile.path)).onComplete;
    final url = await ref.getDownloadURL();

    // use current user to grab the uid and fetch user data (e.g. username)
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'image_url': url});

    // Update all properties to get/show the new user image
    QuerySnapshot userPropertiesQuery = await FirebaseFirestore.instance
        .collection('properties')
        .where('userId', isEqualTo: user.uid)
        .get();

    userPropertiesQuery.docs.forEach((userProperty) {
      userProperty.reference.update({'userProfileImage': url});
    });

    //.update({'image_url': url});

    setState(() {
      _userImage = url;
    });
  }

  void _getUserData() async {
    // close keyboard
    //FocusScope.of(context).unfocus();
    // grab the curren user
    final user = FirebaseAuth.instance.currentUser;
    // use current user to grab the uid and fetch user data (e.g. username)
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) => {
              setState(() {
                _userName = value.data()['username'];
                _userImage = value.data()['image_url'];
                _userEmail = value.data()['email'];
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //appBar: AppBar(title: Text('Settings UI')),
      body: SafeArea(
        child: ListView(scrollDirection: Axis.vertical, children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      margin: EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          _userImage == null
                              ? CircleAvatar(
                                  radius: 80,
                                  backgroundImage: AssetImage(
                                      "assets/images/profile_default.jpg")

                                  //AssetImage('assets/images/profile.jpg'),
                                  )
                              : CachedNetworkImage(
                                  imageUrl: _userImage,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 120.0,
                                    height: 120.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(80),
                                      ),
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFF4845c7),
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: _takePicture,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                //_userName == null ? null : _userName,
                _userName is String ? _userName : 'loading username..',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                _userEmail is String ? _userEmail : 'loading email...',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 8.0, top: 10, bottom: 10),
              //   child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: Text('Settings',
              //           style: TextStyle(
              //               fontWeight: FontWeight.bold, fontSize: 25))),
              // ),
              SettingsList(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                backgroundColor: Colors.white,
                sections: [
                  // SettingsSection(
                  //   title: 'Common',
                  //   // titleTextStyle: TextStyle(fontSize: 30),
                  //   tiles: [
                  //     SettingsTile(
                  //         title: 'Membership',
                  //         //titleTextStyle: TextStyle(color: Colors.black),
                  //         leading: Icon(Icons.verified_user_outlined)),
                  //   ],
                  // ),
                  SettingsSection(
                    title: 'Account',
                    tiles: [
                      SettingsTile(
                          title: 'Phone number', leading: Icon(Icons.phone)),
                      SettingsTile(title: 'Email', leading: Icon(Icons.email)),
                      SettingsTile(
                          title: 'Change password', leading: Icon(Icons.lock)),
                      SettingsTile(
                        title: 'Sign out',
                        leading: Icon(Icons.exit_to_app),
                        onTap: () async {
                          {
                            //Navigator.of(context).pop();
                            //Navigator.of(context).pushReplacementNamed('/');
                            await FirebaseAuth.instance.signOut();
                          }
                          ;
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Misc',
                    tiles: [
                      SettingsTile(
                          title: 'Terms of Service',
                          leading: Icon(Icons.description)),
                      SettingsTile(
                          title: 'Open source licenses',
                          leading: Icon(Icons.collections_bookmark)),
                    ],
                  ),
                  CustomSection(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 22, bottom: 8),
                          child: Image.asset(
                            'assets/images/settings.png',
                            height: 50,
                            width: 50,
                            color: Color(0xFF777777),
                          ),
                        ),
                        Text(
                          'Version: 1.0.0',
                          style: TextStyle(color: Color(0xFF777777)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
