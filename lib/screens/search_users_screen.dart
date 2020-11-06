// import 'package:conspaces/screens/create_chat_screen.dart';
// import 'package:conspaces/widgets/database_service.dart';
// import 'package:flutter/material.dart';
// import '../models/user_model.dart' as User;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';

// class SearchUsersScreen extends StatefulWidget {
//   @override
//   SearchUsersScreenState createState() => SearchUsersScreenState();
// }

// class SearchUsersScreenState extends State<SearchUsersScreen> {
//   final currentUser = FirebaseAuth.instance.currentUser;

//   final TextEditingController _searchController = TextEditingController();
//   List<User.User> _users = [];
//   List<User.User> _selectedUsers = [];

//   _clearSearch() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _searchController.clear();
//     });
//     setState(() {
//       _users = [];
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Search Users'),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.add),
//               onPressed: () {
//                 if (_selectedUsers.length > 0) {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => CreateChatScreen(
//                                 selectedUsers: _selectedUsers,
//                               )));
//                 }
//               },
//             )
//           ],
//         ),
//         body: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 contentPadding: EdgeInsets.symmetric(vertical: 15.0),
//                 border: InputBorder.none,
//                 hintText: 'Search',
//                 prefixIcon: Icon(
//                   Icons.search,
//                   size: 30.0,
//                 ),
//                 suffixIcon: IconButton(
//                     icon: Icon(Icons.clear), onPressed: _clearSearch),
//                 filled: true,
//               ),
//               onSubmitted: (input) async {
//                 if (input.trim().isNotEmpty) {
//                   List<User.User> users =
//                       await Provider.of<DatabaseService>(context, listen: false)
//                           .searchUsers(currentUser.uid, input);
//                   _selectedUsers.forEach((user) => users.remove(user));
//                   setState(() {
//                     _users = users;
//                   });
//                 }
//               },
//             ),
//             Expanded(
//                 child: ListView.builder(
//               itemBuilder: (BuildContext context, int index) {
//                 if (index < _selectedUsers.length) {
//                   // Display selected users
//                   User.User selectedUser = _selectedUsers[index];
//                   return ListTile(
//                     title: Text(selectedUser.username,
//                         style: TextStyle(color: Colors.black)),
//                     trailing: Icon(
//                       Icons.check_circle,
//                       color: Colors.black,
//                     ),
//                     onTap: () {
//                       // remove current user from selected users
//                       _selectedUsers.remove(selectedUser);
//                       // add the user back to the users array
//                       _users.insert(0, selectedUser);
//                       // empty setstate to just rerender the widget tree
//                       setState(() {});
//                     },
//                   );
//                 }
//                 // if it is a user that we have not selected, get his index and return listtile for him
//                 int userIndex = index - _selectedUsers.length;
//                 User.User user = _users[userIndex];
//                 return ListTile(
//                   title: Text(user.username,
//                       style: TextStyle(color: Colors.black)),
//                   trailing: Icon(Icons.check_circle_outline),
//                   onTap: () {
//                     _selectedUsers.add(user);
//                     // add the user back to the users array
//                     _users.remove(user);
//                     // empty setstate to just rerender the widget tree
//                     setState(() {});
//                   },
//                 );
//               },
//               itemCount: _selectedUsers.length + _users.length,
//             ))
//           ],
//         ));
//   }
// }
