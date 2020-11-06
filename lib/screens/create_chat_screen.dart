// import 'package:conspaces/screens/tabs_screen.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import '../models/user_model.dart' as User;
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import '../widgets/database_service.dart';
// import './chat_screen.dart';

// class CreateChatScreen extends StatefulWidget {
//   final List<User.User> selectedUsers;

//   const CreateChatScreen({this.selectedUsers});

//   @override
//   _CreateChatScreenState createState() => _CreateChatScreenState();
// }

// class _CreateChatScreenState extends State<CreateChatScreen> {
//   final _nameFormKey = GlobalKey<FormFieldState>();
//   String _name = '';
//   File _image;
//   bool _isLoading = false;

//   _handleImageFromGallery() async {
//     File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
//     if (imageFile != null) {
//       setState(() {
//         _image = imageFile;
//       });
//     }
//   }

//   _displayChatImage() {
//     return GestureDetector(
//       onTap: _handleImageFromGallery,
//       child: CircleAvatar(
//         radius: 80.0,
//         backgroundColor: Colors.grey[300],
//         backgroundImage: _image != null ? FileImage(_image) : null,
//         child: _image == null
//             ? const Icon(
//                 Icons.add_a_photo,
//                 size: 50.0,
//               )
//             : null,
//       ),
//     );
//   }

//   _submit() async {
//     // check also if not already loading for preventing spamming create button from user
//     if (_nameFormKey.currentState.validate() && !_isLoading) {
//       _nameFormKey.currentState.save();
//       // every chat needs to have an image!
//       if (_image != null) {
//         setState(() {
//           // load new chat
//           _isLoading = true;
//         });
//         // create list of user ids
//         List<String> userIds =
//             widget.selectedUsers.map((user) => user.id).toList();
//         // add current user to user list because we are not inside our selected users
//         // obviously we need to include ourselves to the created chat
//         final currentUser = FirebaseAuth.instance.currentUser;
//         userIds.add(currentUser.uid);

//         Provider.of<DatabaseService>(context, listen: false)
//             .createChat(context, _name, _image, userIds)
//             .then((success) {
//           // createChat returns a future Boolean (always returns true after creating chat was successfull)
//           if (success) {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => TabsScreen(
//                     //chatScreenIndex: true,
//                     ),
//               ),
//               // prevent user from going back
//               (Route<dynamic> route) => false,
//             );
//           }
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Chat'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _isLoading
//                 ? LinearProgressIndicator(
//                     backgroundColor: Colors.blue[200],
//                     valueColor: const AlwaysStoppedAnimation(
//                       Colors.blue,
//                     ),
//                   )
//                 : const SizedBox.shrink(),
//             const SizedBox(height: 30.0),
//             _displayChatImage(),
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: TextFormField(
//                 key: _nameFormKey,
//                 decoration: InputDecoration(labelText: 'Chat Name'),
//                 validator: (input) =>
//                     input.trim().isEmpty ? 'Please enter a chat name' : null,
//                 onSaved: (input) => _name = input,
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             Container(
//               width: 180.0,
//               child: FlatButton(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 color: Colors.blue,
//                 onPressed: _submit,
//                 child: Text(
//                   'Create',
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 20.0,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
