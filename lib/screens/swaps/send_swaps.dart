import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/property_style.dart';
import '../../widgets/property_detail.dart';
import 'package:intl/intl.dart';

class SendSwapsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Widget buildSendRequest(
        dynamic currentProperty,
        String currentUserId,
        BuildContext context,
        int documentLength,
        sendToPropertyList,
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
        if (sendToPropertyList.contains(currentProperty.id)) {
          // wo enthält requestedbypropertylist die request für eine proeprty die gerendert werden soll? im selben index sind in den beiden timestamp listen die start/end dates der request
          index = sendToPropertyList
              .indexWhere((element) => element == currentProperty.id);
          startDateFinal = startDates_copy[index];
          endDateFinal = endDates_copy[index];
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
                    currentUserId,
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
                    ''
                    //false
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
            .collection('requests')
            .where('type', isEqualTo: 'send')
            .where('status', isEqualTo: "pending")
            .snapshots(),
        // whenever the properties collection receives a new value, the function inside of the builder argument is executed
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!streamSnapshot.hasData) {
            return Text('Loading');
          }

          //final documents = streamSnapshot.data.docs;
          final sendBy = streamSnapshot.data.docs;

          // initialized with a default value because whereIn can't receive an empty list
          // can be checked with if len if this list == 1, then there are no received swaps
          List<dynamic> sendToUserList = ['default'];
          List<dynamic> sendToPropertyList = ['default'];
          List<Timestamp> startDates = [Timestamp.now()];
          List<Timestamp> endDates = [Timestamp.now()];

          // Create list of users that requested a swap with the current user
          for (var i = 0; i <= sendBy.length - 1; i++) {
            sendToUserList.add(sendBy[i].data()['RequestSendToUser']);
            sendToPropertyList.add(sendBy[i].data()['RequestSendToProperty']);
            startDates.add(sendBy[i].data()['selectedStartDate']);
            endDates.add(sendBy[i].data()['selectedEndDate']);
          }

          // create stream of properties filtered by the users that the current user has received requests from
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('properties')
                  .where('id', whereIn: sendToPropertyList)
                  .snapshots(),
              builder: (ctx, streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!streamSnapshot.hasData) {
                  return Text('Loading');
                }

                final documents = streamSnapshot.data.docs;

                // List<dynamic> finalProperties = ['default'];

                // // Create list of users that requested a swap with the current user
                // for (var i = 0; i <= sendBy.length - 1; i++) {
                //   if sendToPropertyList[i]
                //   sendToUserList.add(sendBy[i].data()['RequestSendToUser']);
                // }

                if (documents.length == 0) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 25),
                    child: Text('No Send Request.'),
                  );
                } else {
                  return ListView.builder(
                    // order messages from bottom to top
                    //reverse: true,
                    itemCount: documents.length,
                    itemBuilder: (ctx, index) => buildSendRequest(
                        documents[index],
                        user.uid,
                        context,
                        documents.length,
                        sendToPropertyList,
                        startDates,
                        endDates),
                    // itemBuilder: (ctx, index) =>
                    //     //var contain = sendToPropertyList.where((sendToPropertyId) => sendToPropertyId == documents[index].id);
                    //     // (sendToPropertyList.contains(documents[index].id) ==
                    //     //         false)
                    //     //     ? null
                    //     PropertyStyle(
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

// class ReceivedSwapsScreen extends StatefulWidget {
//   @override
//   _ReceivedSwapsScreenState createState() => _ReceivedSwapsScreenState();
// }

// //TODO: Streambuilder Listings.where PropertyID == PropertyId saved in firebase in send requests

// class _ReceivedSwapsScreenState extends State<ReceivedSwapsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Received Swaps'),
//     );
//   }
// }
