// //import 'dart:html';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class ProfileScreen extends StatefulWidget {
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   var _userName;
//   var _userImage;
//   var _userEmail;
//   File _storedImage;

//   void initState() {
//     super.initState();
//     _getUserData();
//   }

//   //TOOD: setState in _takePicture is not really working. The rebuild is not triggered / picture is not updated.
//   Future<void> _takePicture() async {
//     final picker = ImagePicker();
//     final imageFile = await picker.getImage(
//       //source: ImageSource.camera,
//       source: ImageSource.camera,
//       maxWidth: 600,
//     );

//     // grab the curren user
//     final user = FirebaseAuth.instance.currentUser;

//     // Get Image Url
//     final ref = FirebaseStorage.instance
//         .ref()
//         .child('property_images')
//         .child(user.uid + Timestamp.now().toString() + '.jpg');

//     // here we get the image reference (url) from the image file and set it in the user document
//     await ref.putFile(File(imageFile.path)).onComplete;
//     final url = await ref.getDownloadURL();

//     // use current user to grab the uid and fetch user data (e.g. username)
//     final userData = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .update({'image_url': url});
//     // THis is the new version of imagepicker. switch the user image to it if needed.
//     setState(() {
//       _userImage = url;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(
//           height: 24,
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: 24,
//             vertical: 24,
//           ),
//           child: Column(
//             children: [
//               Container(
//                 height: 120,
//                 width: 120,
//                 margin: EdgeInsets.only(top: 10),
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 80,
//                       backgroundImage:
//                           _userImage != null ? NetworkImage(_userImage) : null,
//                       //AssetImage('assets/images/profile.jpg'),
//                     ),
//                     Align(
//                       alignment: Alignment.bottomRight,
//                       child: Container(
//                         height: 30,
//                         width: 30,
//                         decoration: BoxDecoration(
//                           color: Colors.yellow,
//                           shape: BoxShape.circle,
//                         ),
//                         child: InkWell(
//                           onTap: _takePicture,
//                           child: Icon(
//                             Icons.edit,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Text(
//           //_userName == null ? null : _userName,
//           _userName is String ? _userName : 'loading username..',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         SizedBox(height: 5),
//         Text(
//           _userEmail is String ? _userEmail : 'loading email...',
//           style: TextStyle(fontSize: 15, color: Colors.black),
//         ),
//         SizedBox(height: 10),
//         Container(
//           height: 40,
//           width: 200,
//           decoration: BoxDecoration(
//             color: Colors.yellowAccent[700],
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Center(
//             child: Text(
//               'Get Membership',
//               style: TextStyle(
//                 //fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListView(
//             children: [
//               ProfileListItem(
//                 icon: Icons.security,
//                 text: 'Privacy',
//               ),
//               ProfileListItem(
//                 icon: Icons.history,
//                 text: 'Purchase History',
//               ),
//               ProfileListItem(
//                 icon: Icons.help_outline,
//                 text: 'Help & Support',
//               ),
//               ProfileListItem(
//                 icon: Icons.settings,
//                 text: 'Settings',
//               ),
//               ProfileListItem(
//                 icon: Icons.supervised_user_circle,
//                 text: 'Invite a Friend',
//               ),
//               GestureDetector(
//                 onTap: () {
//                   //Navigator.of(context).pop();
//                   //Navigator.of(context).pushReplacementNamed('/');
//                   FirebaseAuth.instance.signOut();
//                 },
//                 child: ProfileListItem(
//                   icon: Icons.exit_to_app,
//                   text: 'Logout',
//                   hasNavigation: false,
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   void _getUserData() async {
//     // close keyboard
//     //FocusScope.of(context).unfocus();
//     // grab the curren user
//     final user = FirebaseAuth.instance.currentUser;
//     // use current user to grab the uid and fetch user data (e.g. username)
//     final userData = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .get()
//         .then((value) => {
//               setState(() {
//                 _userName = value.data()['username'];
//                 _userImage = value.data()['image_url'];
//                 _userEmail = value.data()['email'];
//               })
//             });
//   }
// }

// class ProfileListItem extends StatelessWidget {
//   final IconData icon;
//   final text;
//   final bool hasNavigation;

//   ProfileListItem({
//     this.icon,
//     this.text,
//     this.hasNavigation = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 60,
//       margin: EdgeInsets.symmetric(horizontal: 25).copyWith(bottom: 20),
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         color: Theme.of(context).backgroundColor,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             this.icon,
//             size: 25,
//           ),
//           SizedBox(width: 25),
//           Text(
//             this.text,
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Spacer(),
//           if (this.hasNavigation)
//             Icon(
//               Icons.keyboard_arrow_right,
//               size: 40,
//             ),
//         ],
//       ),
//     );
//   }
// }
