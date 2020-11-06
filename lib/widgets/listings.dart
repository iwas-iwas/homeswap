import 'package:conspacesapp/screens/explore_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './property_style.dart';
import 'package:async/async.dart';
import 'package:async/async.dart' show StreamZip;
import '../screens/tabs_screen.dart';

class Listings extends StatelessWidget {
  // TODO: Filter Listings by pickedLocation & pickedDestination
  String pickedLocation;
  String pickedDestination;

  Listings(this.pickedLocation, this.pickedDestination);

  @override
  Widget build(BuildContext context) {
    // TODO: current user is not needed for dislpaying the listings, it is needed when creating and storing new property objects. s
    // so remove current user here??
    final user = FirebaseAuth.instance.currentUser;
    // once we got the currently logged in user, return streambuilder and build the list view new for every new property
    //return StreamBuilder(
    return ListView(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TabsScreen(),
                    ),
                  );
                  // Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.repeat,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        HeadingFromExplore(pickedDestination),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('properties')
                .where('location', isEqualTo: pickedDestination)
                .where('destination', whereIn: [pickedLocation, 'ffa'])
                //TODO: ORDER BY HAT DEN BUILDER GEBROCHEN, DA VERMUTLICH DER USERID INDEX DER EINGERICHTET IST DADURCH AKTIV WURDE! GGF. WEITEREN INDEX ERSTELLEn FÜR LOCATION/DESTINATION
                //.orderBy('createdAt', descending: true)
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
              final documents = streamSnapshot.data.docs;

              return ListView.builder(
                //scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                // order messages from bottom to top
                //reverse: true,
                itemCount: documents.length,
                // itemBuilder: (ctx, index) => Container(
                //   padding: EdgeInsets.all(8),
                //   child: Text(documents[index]['title']),
                // ),
                itemBuilder: (ctx, index) => PropertyStyle(
                  documents[index].data()['title'],
                  //documents[index]['userId'],
                  // each property contains the username, specified in new_property upon pressing send
                  documents[index].data()['username'],
                  documents[index].data()['userImage'],
                  documents[index].data()['location'],
                  documents[index].data()['destination'],
                  // TODO: evaluate if "is me" is needed. maybe to give specific rights or highlight smth?
                  documents[index].data()['userId'] == user.uid,
                  documents[index].data()['userId'],
                  user.uid,
                  documents[index].id,
                  false,
                  documents[index].data()['latitude'],
                  documents[index].data()['longitude'],
                  documents[index].data()['bathrooms'],
                  documents[index].data()['bedrooms'],
                  documents[index].data()['kitchen'],
                  documents[index].data()['workspaces'],
                  documents[index].data()['sqm'],
                  documents[index].data()['firstAdditionalImage'],
                  documents[index].data()['secondAdditionalImage'],
                  documents[index].data()['userProfileImage'],
                  // make sure that flutter makes sure to efficiently update the list with new items
                  key: ValueKey(documents[index].id),
                ),
              );
            }),
      ],
    );
    //},
    //);
  }
}

class HeadingFromExplore extends StatelessWidget {
  HeadingFromExplore(this.pickedDestination);

  final String pickedDestination;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 25),
          child: Text(
            "City",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
          child: Text(
            pickedDestination,
            style: TextStyle(
                fontSize: 36, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
