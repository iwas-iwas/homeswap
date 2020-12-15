import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListingsUniqueSelection extends StatefulWidget {
  @override
  _ListingsUniqueSelectionState createState() =>
      _ListingsUniqueSelectionState();
}

class _ListingsUniqueSelectionState extends State<ListingsUniqueSelection> {
  var _selectedProperty;

  @override
  Widget build(BuildContext context) {
    // so remove current user here??
    final user = FirebaseAuth.instance.currentUser;
    // once we got the currently logged in user, return streambuilder and build the list view new for every new property
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('properties')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
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
          final documents = streamSnapshot.data.docs;

          return Container(
              height: 150.0,
              width: 200.0,
              child: ListView.builder(
                // order messages from bottom to top
                reverse: true,
                itemCount: documents.length,
                // itemBuilder: (ctx, index) => Container(
                //   padding: EdgeInsets.all(8),
                //   child: Text(documents[index]['title']),
                // ),
                itemBuilder: (ctx, index) => ListTile(
                  title: Text(
                      "${documents[index].data()['title']}, ${documents[index].data()['location']}"),
                  leading: Radio(
                    value: documents[index].id,
                    groupValue: _selectedProperty,
                    onChanged: (selectedProperty) {
                      setState(() {
                        print("selected ${selectedProperty}");
                        _selectedProperty = selectedProperty;
                      });
                    },
                  ),
                ),
                // Row(
                //       children: [
                //         Text("${documents[index].data()['title']}, ${documents[index].data()['locatiom']}"),

                //       ],
              )

              //PropertyStyle(
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
        });
  }
}
