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

class SendSwapsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // once we got the currently logged in user, return streambuilder and build the list view new for every new property
    //return StreamBuilder(
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('requests')
            .where('type', isEqualTo: 'send')
            .where('status', isEqualTo: "pending")
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

          //final documents = streamSnapshot.data.docs;
          final pendingSend = streamSnapshot.data.docs;

          if (pendingSend.length == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 25),
              child: Text(
                  'no pending send requests. search the explore page for spaces you like!'),
            );
          } else {
            return ListView.builder(
                itemCount: pendingSend.length,
                itemBuilder: (ctx, index) =>
                    SendRequest(pendingSend[index], user.uid));
          }
        });
  }
}
