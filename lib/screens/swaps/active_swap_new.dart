import 'package:conspacesapp/screens/swaps/ActiveRequest.dart';
import 'package:conspacesapp/screens/swaps/SendRequest.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../constants.dart';
import '../../widgets/property_style.dart';
import '../../widgets/property_detail.dart';
import 'package:intl/intl.dart';

import 'ReceivedRequest.dart';

class ActiveSwapsScreen extends StatelessWidget {
  ActiveSwapsScreen(this.currentUserId);

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    //final user = FirebaseAuth.instance.currentUser;
    // once we got the currently logged in user, return streambuilder and build the list view new for every new property
    //return StreamBuilder(

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('requests')
            .where('status', isEqualTo: "accepted")
            .snapshots(),
        // whenever the properties collection receives a new value, the function inside of the builder argument is executed
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              //child: CircularProgressIndicator(),
              child: SpinKitRotatingCircle(
                color: kPrimaryColor,
                size: 50.0,
              ),
            );
          }
          if (!streamSnapshot.hasData) {
            return Text('Loading');
          }

          final activeRequests = streamSnapshot.data.docs;

          if (activeRequests.length == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 25),
              child: Text('no active swaps.'),
            );
          } else {
            return ListView.builder(
                itemCount: activeRequests.length,
                itemBuilder: (ctx, index) =>
                    ActiveRequest(activeRequests[index], currentUserId));
          }
        });
  }
}
