import 'package:conspacesapp/screens/swaps/active_swap.dart';
import 'package:conspacesapp/screens/swaps/received_swap.dart';
import 'package:conspacesapp/screens/swaps/send_swaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../auth_screen.dart';
import '../../constants.dart';

class SwapsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SwapsScreenState();
  }
}

class _SwapsScreenState extends State<SwapsScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;

  TabController _tabController;
  bool _isPremium = true;
  bool _isAnon = false;
  String currentUserId;

  void initState() {
    super.initState();

    _checkPremiumStatus();
    if (!_isAnon) {
      _tabController = TabController(vsync: this, length: 3);
    }
  }

  Future<void> _checkPremiumStatus() async {
    //await Future.delayed(Duration(seconds: 1));
    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await Future.delayed(Duration(seconds: 1));
      user = FirebaseAuth.instance.currentUser;
    }

    if (user == null) {
      await Future.delayed(Duration(seconds: 1));
      user = FirebaseAuth.instance.currentUser;
    }

    if (user.isAnonymous) {
      setState(() {
        _isAnon = true;
      });
    } else {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (_isAnon)
      return Scaffold(
        backgroundColor: Colors.white,
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
    if (!_isAnon && _isPremium != null && currentUserId != null)
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0), // here the desired height
          child: AppBar(
            backgroundColor: Colors.white,
            centerTitle: false,
            // AppBar title stays left with "automaticallyImplyLeading" set to false.
            automaticallyImplyLeading: false,
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
                        child: Text("Received",
                            style: TextStyle(color: Colors.black)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text("Active",
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
            ReceivedSwapsScreen(_isPremium),
            ActiveSwapsScreen(currentUserId),
            SendSwapsScreen(),
          ],
        ),
      );
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SpinKitRotatingCircle(
            color: kPrimaryColor,
            size: 50.0,
          ),
        ));
  }
}
