// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NewProperty extends StatefulWidget {
//   @override
//   _NewPropertyState createState() => _NewPropertyState();
// }

// class _NewPropertyState extends State<NewProperty> {
//   final _controller = new TextEditingController();
//   var _enteredMessage = '';

//   // async because FirebaseAuth.instance.currentUser() returns a Future of the current user
//   void _sendMessage() async {
//     // close keyboard
//     FocusScope.of(context).unfocus();
//     // grab the curren user
//     final user = FirebaseAuth.instance.currentUser;
//     // use current user to grab the uid and fetch user data (e.g. username)
//     final userData = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .get();
//     // add new message to firebase. snapshot in streambuilder will pick it up and display. will execute after we got the usure (await future finished)
//     FirebaseFirestore.instance.collection('properties').add({
//       'title': _enteredMessage,
//       'createdAt': Timestamp.now(),
//       // TODO: this user id can be used to retreive contcat information, user image etc. for the property-detail-view of each listing!
//       'userId': user.uid,
//       // for every new property, the username of the creator is stored
//       'username': userData.data()['username'],
//       //'userImage': userData.data()['image_url']
//     });

//     // clear message in textfield after onpressed is done
//     _controller.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(top: 8),
//       padding: EdgeInsets.all(8),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               // only to clear textfield after onpressed is done (put to firebase done)
//               controller: _controller,
//               decoration: InputDecoration(labelText: 'Send a message'),
//               onChanged: (value) {
//                 setState(() {
//                   _enteredMessage = value;
//                 });
//               },
//             ),
//           ),
//           IconButton(
//               // if textfield empty dont enable the send button
//               onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
//               color: Theme.of(context).primaryColor,
//               icon: Icon(Icons.send))
//         ],
//       ),
//     );
//   }
// }
