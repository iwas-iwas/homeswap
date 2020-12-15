import 'package:flutter/material.dart';
import '../widgets/listings.dart';

class ListingsScreen extends StatelessWidget {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  final String pickedLocation;
  final String pickedDestination;

  ListingsScreen(this.pickedLocation, this.pickedDestination);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              //   child: Padding(
              //     padding: const EdgeInsets.only(top: 40, left: 10),
              //     child: Icon(
              //       Icons.arrow_back_ios,
              //       color: Colors.black,
              //       size: 24,
              //     ),
              //   ),
              // ),
              Expanded(child: Listings(pickedLocation, pickedDestination)),
            ],
          ),
        ),
      ),
    );
  }
}
