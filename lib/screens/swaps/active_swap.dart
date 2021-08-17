import 'package:conspacesapp/screens/swaps/active_swap_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../constants.dart';

class ActiveSwapsScreen extends StatelessWidget {
  ActiveSwapsScreen(this.currentUserId);

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('requests')
            .where('status', isEqualTo: "accepted")
            .snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
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
