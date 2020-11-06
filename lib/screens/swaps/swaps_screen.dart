import 'package:flutter/material.dart';
import './active_swap.dart';
import './received_swaps.dart';
import './send_swaps.dart';
import '../../constants.dart';

// class SwapsScreen extends StatefulWidget {
//   @override
//   _SwapsScreenState createState() => _SwapsScreenState();
// }

// class _SwapsScreenState extends State<SwapsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return new DefaultTabController(
//       length: 3,
//       child: new Scaffold(
//         appBar: new AppBar(
//           centerTitle: false,
//           title: Padding(
//             padding: EdgeInsets.only(bottom: 40, top: 40),
//             child: Text('Requests'),
//           ),
//           backgroundColor: Colors.white,
//           flexibleSpace: new Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0),
//                 child: new TabBar(
//                   isScrollable: true,
//                   tabs: [
//                     Text("Active", style: TextStyle(color: Colors.black)),
//                     new Text("Received", style: TextStyle(color: Colors.black)),
//                     new Text("Send", style: TextStyle(color: Colors.black)),
//                     // new Tab(icon: new Icon(Icons.swap_horizontal_circle)),
//                     // new Tab(icon: new Icon(Icons.history)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             ActiveSwapsScreen(),
//             ReceivedSwapsScreen(),
//             SendSwapsScreen(),
//           ],
//         ),
//       ),
//     );
//   }
// }

class SwapsScreen extends StatefulWidget {
  final String title;

  const SwapsScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SwapsScreenState();
  }
}

class _SwapsScreenState extends State<SwapsScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  // void _toggleTab() {
  //   _tabIndex = _tabController.index + 1;
  //   _tabController.animateTo(_tabIndex);
  // }

  @override
  Widget build(BuildContext context) {
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
