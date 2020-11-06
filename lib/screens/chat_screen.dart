// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import './search_users_screen.dart';
// import '../constants.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/chat_model.dart';
// import '../constants.dart';
// import 'package:intl/intl.dart';
// import './chat_screen_detail.dart';

// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   _buildChat(Chat chat, String currentUserId) {
//     final bool isRead = chat.readStatus[currentUserId];
//     final TextStyle readStyle = TextStyle(
//       fontWeight: isRead ? FontWeight.w400 : FontWeight.bold,
//     );
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.white,
//         radius: 28.0,
//         backgroundImage: CachedNetworkImageProvider(chat.imageUrl),
//       ),
//       title: Text(
//         chat.username,
//         overflow: TextOverflow.ellipsis,
//       ),
//       subtitle: chat.recentSender.isEmpty
//           ? Text('Chat Created',
//               overflow: TextOverflow.ellipsis, style: readStyle)
//           : chat.recentMessage != null
//               ? Text(
//                   '${chat.memberInfo[chat.recentSender]['username']}: ${chat.recentMessage}',
//                   overflow: TextOverflow.ellipsis,
//                   style: readStyle,
//                 )
//               // if recent message is null
//               : Text(
//                   '${chat.memberInfo[chat.recentSender]['name']} send an image',
//                   overflow: TextOverflow.ellipsis,
//                   style: readStyle,
//                 ),
//       trailing: Text(
//         timeFormat.format(
//           chat.recentTimestamp.toDate(),
//         ),
//         style: readStyle,
//       ),
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => ChatScreenDetail(
//             chat: chat,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF4845c7),
//         title: Text('Chats'),
//         actions: [
//           IconButton(
//               icon: Icon(Icons.add),
//               onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => SearchUsersScreen(),
//                   )))
//         ],
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('chats')
//             .where('memberIds', arrayContains: currentUser.uid)
//             .orderBy('recentTimestamp', descending: true)
//             .snapshots(),
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if (!snapshot.hasData) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           // seperated creats a divider between each element
//           return ListView.separated(
//               itemBuilder: (BuildContext context, int index) {
//                 Chat chat = Chat.fromDoc(snapshot.data.documents[index]);

//                 return _buildChat(chat, currentUser.uid);
//               },
//               separatorBuilder: (BuildContext context, int index) {
//                 return const Divider(
//                   thickness: 1.0,
//                 );
//               },
//               itemCount: snapshot.data.docs.length);
//         },
//       ),
//     );
//   }
// }
