//import 'package:conspaces/screens/listings_screen.dart';
import 'package:conspacesapp/constants.dart';
import 'package:conspacesapp/screens/explore_screen_old.dart';

import './swaps/swaps_screen.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_fire/screens/chat_screen.dart';
import 'explore_screen.dart';
//import 'google_search.dart';
import './user_listings_screen.dart';
import './profile_screen.dart';
import './chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './settings_screen.dart';
//import '../widgets/app_drawer.dart';
//import './saved_screen.dart';
import './Welcome/welcome_screen.dart';

class TabsScreen extends StatefulWidget {
  // bool chatScreenIndex;

  // TabsScreen({this.chatScreenIndex = false});

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

// final String currentUserId = FirebaseAuth.instance.currentUser.uid;

class _TabsScreenState extends State<TabsScreen> {
  final List<Map<String, Object>> _pages = [
    {'page': ExploreScreenTest(), 'title': 'Explore'},
    {'page': SwapsScreen(), 'title': 'Swaps'},
    {'page': UserListingsScreen(), 'title': 'Listings'},
    // at the moment savedscreen constructor expects a string, which is given in search_field.dart
    //{'page': SavedScreen(), 'title': 'Saved'},
    //{'page': ChatScreen(), 'title': 'Chat'},
    {'page': SettingsScreen(), 'title': 'Profile'},
    //{'page': WelcomeScreen(), 'title': 'Auth'},
  ];

  int _selectedPageIndex = 0;
  Widget _currentPage = ExploreScreenTest();

  // Select Page: SetState to change the Widget-index of _pages to render the specific Screen based on a user selecting one of the two tabs
  // flutter automatically provides the index of the clicked tab through ontap argument in the bottom navitation bar widget
  void _selectPage(int index) {
    setState(() {
      // in case a user returns from creating a chat, set the rendering of chatscreen to false
      // otherwise the bottom sheet indexing stops working ebcause chatscreenindex is stuck on true
      //widget.chatScreenIndex = false;
      _selectedPageIndex = index;
      _currentPage = _pages[_selectedPageIndex]['page'];
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //drawer: AppDrawer(),
      //body: widget.chatScreenIndex ? ChatScreen() : _currentPage,
      body: _currentPage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        fixedColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            //title: Text('Explore'),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            //title: Text('Swaps'),
            label: 'Swaps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            //title: Text('Listings'),
            label: 'Listings',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.message),
          //   title: Text('Chat'),
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            //title: Text('Profile'),
            label: 'Profile',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.login),
          //   //title: Text('Profile'),
          //   label: 'Auth',
          // ),
        ],
      ),
    );
  }
}
