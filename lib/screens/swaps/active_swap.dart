import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../constants.dart';
import '../../widgets/property_style.dart';
import '../../widgets/property_detail.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ActiveSwapsScreen extends StatelessWidget {
  ActiveSwapsScreen(String currentUserId);

  String currentUserId;

  // ActiveSwapsScreen(this.isPremium);

  // final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Widget buildAcceptedRequest(
        dynamic currentProperty,
        String currentUserId,
        BuildContext context,
        int documentLength,
        activeList,
        List<Timestamp> startDates,
        List<Timestamp> endDates) {
      List<Timestamp> startDates_copy = startDates;
      List<Timestamp> endDates_copy = endDates;

      // List<Timestamp> startDatesFinal = [];
      // List<Timestamp> endDatesFinal = [];
      Timestamp startDateFinal = Timestamp.now();
      Timestamp endDateFinal = Timestamp.now();
      int index = 0;

      for (var i = 0; i <= documentLength - 1; i++) {
        if (activeList.contains(currentProperty.id)) {
          // wo enthält requestedbypropertylist die request für eine proeprty die gerendert werden soll? im selben index sind in den beiden timestamp listen die start/end dates der request
          index =
              activeList.indexWhere((element) => element == currentProperty.id);
          startDateFinal = startDates_copy[index];
          endDateFinal = endDates_copy[index];
          // startDatesFinal.add(startDates_copy[index]);
          // endDatesFinal.add(endDates_copy[index]);
        }
      }
      return Card(
        child: ListTile(
          leading: currentProperty.data()['userProfileImage'] == null
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(
                      "assets/images/profile_default.jpg"), // no matter how big it is, it won't overflow
                )
              : CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      NetworkImage(currentProperty.data()['userProfileImage']),
                ),
          // : CachedNetworkImage(
          //     imageUrl: currentProperty.data()['userProfileImage'],
          //     imageBuilder: (context, imageProvider) => Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.all(Radius.circular(25)),
          //         image: DecorationImage(
          //             image: imageProvider, fit: BoxFit.cover),
          //       ),
          //     ),
          //     placeholder: (context, url) =>
          //         Center(child: CircularProgressIndicator()),
          //     errorWidget: (context, url, error) => Icon(Icons.error),
          //   ),
          title: Text(
            '${currentProperty.data()['username']}, ${currentProperty.data()['location']}',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          subtitle: Text(
            '${DateFormat.yMd().format(startDateFinal.toDate())} - ${DateFormat.yMd().format(endDateFinal.toDate())}',
            style: TextStyle(fontSize: 15),
          ),
          //trailing: Icon(Icons.check_box),
          // trailing: IconButton(
          //   icon: Icon(Icons.chat),
          //   color: Colors.yellowAccent,
          //   onPressed: () {},
          // ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detail(
                  currentProperty.data()['title'],
                  currentProperty.data()['username'],
                  currentProperty.data()['userImage'],
                  currentProperty.data()['location'],
                  currentProperty.data()['userId'],
                  user.uid,
                  //currentUserId,
                  currentProperty.id,
                  true,
                  currentProperty.data()['latitude'],
                  currentProperty.data()['longitude'],
                  currentProperty.data()['bathrooms'],
                  currentProperty.data()['bedrooms'],
                  currentProperty.data()['kitchen'],
                  currentProperty.data()['workspaces'],
                  currentProperty.data()['sqm'],
                  currentProperty.data()['firstAdditionalImage'],
                  currentProperty.data()['secondAdditionalImage'],
                  false,
                  currentProperty.data()['userProfileImage'],
                  currentProperty.data()['userMail'],
                  currentProperty.data()['fullAddress'],
                  false,
                ),
              ),
            );
          },
        ),
      );
    }

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            //.doc(currentUserId)
            .collection('requests')
            .where('status', isEqualTo: "accepted")
            .snapshots(),
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

          final requests = streamSnapshot.data.docs;

          List<dynamic> requestPropertyList = ['default'];
          List<Timestamp> startDates = [Timestamp.now()];
          List<Timestamp> endDates = [Timestamp.now()];

          for (var i = 0; i <= requests.length - 1; i++) {
            requestPropertyList.add(requests[i].data()['propertyId']);

            startDates.add(requests[i].data()['selectedStartDate']);
            endDates.add(requests[i].data()['selectedEndDate']);
          }

          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('properties')
                  .where('id', whereIn: requestPropertyList)
                  //.orderBy('createdAt', descending: true)
                  .snapshots(),
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
                final documents = streamSnapshot.data.docs;

                if (documents.length == 0) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 25),
                    child: Text('No Active Request.'),
                  );
                } else {
                  return ListView.builder(
                    // order messages from bottom to top
                    //reverse: true,
                    itemCount: documents.length,
                    itemBuilder: (ctx, index) => buildAcceptedRequest(
                        documents[index],
                        //user.uid,
                        currentUserId,
                        context,
                        documents.length,
                        requestPropertyList,
                        startDates,
                        endDates),
                    //  itemBuilder: (ctx, index) => PropertyStyle(
                    //   documents[index].data()['title'],
                    //   //documents[index]['userId'],
                    //   // each property contains the username, specified in new_property upon pressing send
                    //   documents[index].data()['username'],
                    //   documents[index].data()['userImage'],
                    //   documents[index].data()['location'],
                    //   documents[index].data()['destination'],
                    //   // TODO: evaluate if "is me" is needed. maybe to give specific rights or highlight smth?
                    //   documents[index].data()['userId'] == user.uid,
                    //   documents[index].data()['userId'],
                    //   user.uid,
                    //   documents[index].id,
                    //   // make sure that flutter makes sure to efficiently update the list with new items
                    //   key: ValueKey(documents[index].id),
                    // ),
                  );
                }
              });
        });
  }
}
