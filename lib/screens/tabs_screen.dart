import 'package:conspacesapp/screens/explore_screen.dart';
import './swaps/swaps_screen.dart';
import 'package:flutter/material.dart';
import './user_listings_screen.dart';
import 'settings/settings_screen.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

// final String currentUserId = FirebaseAuth.instance.currentUser.uid;

class _TabsScreenState extends State<TabsScreen> {
  final List<Map<String, Object>> _pages = [
    {'page': ExploreScreen(), 'title': 'Explore'},
    {'page': SwapsScreen(), 'title': 'Swaps'},
    {'page': UserListingsScreen(), 'title': 'Listings'},
    {'page': SettingsScreen(), 'title': 'Profile'},
  ];

  int _selectedPageIndex = 0;
  Widget _currentPage = ExploreScreen();
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      _currentPage = _pages[_selectedPageIndex]['page'];
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        ],
      ),
    );
  }
}
