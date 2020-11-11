import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_screen.dart';
import './active_swap.dart';
import './received_swaps.dart';
import './send_swaps.dart';
import '../../constants.dart';

class SwapsScreen extends StatefulWidget {
  // final String title;

  // const SwapsScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SwapsScreenState();
  }
}

class _SwapsScreenState extends State<SwapsScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;

  TabController _tabController;

  bool _isAnon = false;

  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user.isAnonymous) {
      setState(() {
        _isAnon = true;
      });
    } else {
      _tabController = TabController(vsync: this, length: 3);
    }
  }

  // void _toggleTab() {
  //   _tabIndex = _tabController.index + 1;
  //   _tabController.animateTo(_tabIndex);
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (_isAnon)
      return Scaffold(
        //key: _scaffoldKey,
        //backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        //body: AuthForm(_submitAuthForm, _isLoading, _scaffoldKey),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Swaps',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(height: 10),
                Text(
                  'Sign up to view and mange your active, received and send swaps.',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: size.width * 0.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FlatButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      color: kPrimaryColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthScreen(
                              isAnon: true,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Signup',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0), // here the desired height
        child: AppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 40),
            child: Text('Requests',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 26)),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                //width: MediaQuery.of(context).size.width / 2,
                width: double.infinity,
                child: TabBar(
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 2,
                      color: const Color(0xFF4845c7),
                    ),
                    insets: EdgeInsets.only(left: 0, right: 8, bottom: 0),
                  ),
                  isScrollable: true,
                  controller: _tabController,
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child:
                          Text("Active", style: TextStyle(color: Colors.black)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text("Received",
                          style: TextStyle(color: Colors.black)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child:
                          Text("Send", style: TextStyle(color: Colors.black)),
                    ),
//                     // new Tab(icon: new Icon(Icons.swap_horizontal_circle)),
//                     // new Tab(icon: new Icon(Icons.history)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ActiveSwapsScreen(),
          ReceivedSwapsScreen(),
          SendSwapsScreen(),
        ],
      ),
    );
  }
}
