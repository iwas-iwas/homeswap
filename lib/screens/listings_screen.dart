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
              Expanded(child: Listings(pickedLocation, pickedDestination)),
            ],
          ),
        ),
      ),
    );
  }
}
