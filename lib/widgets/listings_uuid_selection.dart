import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants.dart';

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
          final documents = streamSnapshot.data.docs;

          return Container(
              height: 150.0,
              width: 200.0,
              child: ListView.builder(
                // order messages from bottom to top
                reverse: true,
                itemCount: documents.length,
                itemBuilder: (ctx, index) => ListTile(
                  title: Text(
                      "${documents[index].data()['title']}, ${documents[index].data()['locationPlaceId']}"),
                  leading: Radio(
                    value: documents[index].id,
                    groupValue: _selectedProperty,
                    onChanged: (selectedProperty) {
                      setState(() {
                        _selectedProperty = selectedProperty;
                      });
                    },
                  ),
                ),
              ));
        });
  }
}
