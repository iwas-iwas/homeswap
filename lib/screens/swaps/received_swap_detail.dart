import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conspacesapp/main.dart';
import 'package:conspacesapp/widgets/property_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class ReceivedRequest extends StatefulWidget {
  ReceivedRequest(this.request, this.currentUserId, this.isPremium);

  final dynamic request;
  final String currentUserId;
  final bool isPremium;

  @override
  _ReceivedRequestState createState() => _ReceivedRequestState();
}

class _ReceivedRequestState extends State<ReceivedRequest> {
  DocumentSnapshot _myProperty;
  DocumentSnapshot _swapPartnerProperty;

  void initState() {
    super.initState();
    _getSpacesData();
  }

  void _getSpacesData() async {
    DocumentSnapshot myProperty = await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.request.data()['myProperty'])
        .get();

    DocumentSnapshot swapPartnerProperty = await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.request.data()['swapPartnerProperty'])
        .get();

    setState(() {
      _myProperty = myProperty;
      _swapPartnerProperty = swapPartnerProperty;
    });
  }

  bool checkOverlap(List<Timestamp> endA, dynamic startB) {
    // if enda => startb return true else return false (start a <= endb already done in .where firebase fiter)
    for (int i = 0; i < endA.length; i++) {
      int check = (endA[i].toDate()).compareTo(startB);

      if (check >= 0) {
        return true; // compareTo returns 0 if equal and a positive integer if a is greater than b. in both cases the date-ranges are overlapping
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_myProperty != null && _swapPartnerProperty != null)
      return Card(
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detail(
                    _swapPartnerProperty.data()['title'],
                    _swapPartnerProperty.data()['username'],
                    _swapPartnerProperty.data()['userImage'],
                    //currentProperty.data()['location'],
                    '', // not used in detail
                    _swapPartnerProperty.data()['userId'],
                    widget.currentUserId,
                    _swapPartnerProperty.id,
                    true,
                    // currentProperty.data()['latitude'],
                    // currentProperty.data()['longitude'],
                    _swapPartnerProperty.data()['bathrooms'],
                    _swapPartnerProperty.data()['bedrooms'],
                    _swapPartnerProperty.data()['kitchen'],
                    _swapPartnerProperty.data()['workspaces'],
                    _swapPartnerProperty.data()['sqm'],
                    _swapPartnerProperty.data()['firstAdditionalImage'],
                    _swapPartnerProperty.data()['secondAdditionalImage'],
                    false,
                    _swapPartnerProperty.data()['userProfileImage'],
                    _swapPartnerProperty.data()['userMail'],
                    '',
                    _swapPartnerProperty.data()['locationFullPlaceId'],
                    false),
              ),
            );
          },
          contentPadding: const EdgeInsets.all(5.0),
          isThreeLine: true,
          //leading: Icon(Icons.swap_horiz),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: TextStyle(
                      //fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'From: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: _swapPartnerProperty.data()['username'],
                      ),
                    ],
                  ),
                ),
                //Text('From: ${_swapPartnerProperty.data()['username']}'),
                SizedBox(height: 5.0),
                RichText(
                  text: TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: TextStyle(
                      //fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Requested Space: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: _myProperty.data()['title'],
                      ),
                    ],
                  ),
                ),
                //Text('Requested Space: ${_myProperty.data()['title']}'),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                  onTap: () async {
                    if (!widget.isPremium) {
                      SnackBar snackBar = SnackBar(
                        content: Text(
                          'Accepting swap requests requires a premium account.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color(0xFF4845c7),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    } else {
                      QuerySnapshot activeRequests = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(widget.currentUserId)
                          .collection('requests')
                          .where('status', isEqualTo: "accepted")
                          .get();

                      QuerySnapshot activeRequestsSwapPartner =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_swapPartnerProperty.data()['userId'])
                              .collection('requests')
                              .where('status', isEqualTo: "accepted")
                              .where("selectedStartDate",
                                  isLessThanOrEqualTo:
                                      widget.request.data()['selectedEndDate'])
                              .get();

                      List<Timestamp> selectedEndDates = [];

                      for (int i = 0;
                          i < activeRequestsSwapPartner.docs.length;
                          i++) {
                        var a = activeRequestsSwapPartner.docs[i];
                        // mit der ID kann ich theoreisch fromDoc callen
                        // print(a.id);
                        // print(a.data()['selectedStartDate']);
                        selectedEndDates.add(a.data()['selectedEndDate']);
                      }

                      bool unavailable = checkOverlap(selectedEndDates,
                          widget.request.data()['selectedStartDate'].toDate());

                      if (activeRequests.docs.length >= 5 || unavailable) {
                        SnackBar snackBar = SnackBar(
                          content: Text(
                            unavailable
                                ? 'An active swap ${_swapPartnerProperty.data()['username']} overlaps with the time window of this request'
                                : 'You reached the limit of five active Swaps.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color(0xFF4845c7),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      } else {
                        // update die request vom current user (receiver) auf accepted
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.currentUserId)
                            .collection('requests')
                            .where('type', isEqualTo: 'received')
                            .where('swapPartnerProperty',
                                isEqualTo: _swapPartnerProperty.id)
                            .get()
                            .then((filteredAcceptedProperty) =>
                                filteredAcceptedProperty.docs
                                    .forEach((accProperty) {
                                  accProperty.reference
                                      .update({'status': 'accepted'});
                                }));

                        // filter die request von dem absender (swap partner) in dem ich in seinen requests die property vom receiver suche
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(_swapPartnerProperty.data()['userId'])
                            .collection('requests')
                            .where('type', isEqualTo: 'send')
                            .where('swapPartnerProperty',
                                isEqualTo: _myProperty.id)
                            .get()
                            .then((filteredAcceptedProperty) =>
                                filteredAcceptedProperty.docs
                                    .forEach((accProperty) {
                                  accProperty.reference
                                      .update({'status': 'accepted'});
                                }));
                      }
                    }
                  },
                  child: Icon(
                    Icons.check_box,
                    color: Colors.greenAccent,
                  )),
              SizedBox(width: 20),
              InkWell(
                  onTap: () {
                    // update die request vom current user (receiver) auf accepted
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.currentUserId)
                        .collection('requests')
                        .where('type', isEqualTo: 'received')
                        .where('swapPartnerProperty',
                            isEqualTo: _swapPartnerProperty.id)
                        .get()
                        .then((filteredAcceptedProperty) =>
                            filteredAcceptedProperty.docs
                                .forEach((accProperty) {
                              accProperty.reference.delete();
                            }));

                    // filter die request von dem absender (swap partner) in dem ich in seinen requests die property vom receiver suche
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(_swapPartnerProperty.data()['userId'])
                        .collection('requests')
                        .where('type', isEqualTo: 'send')
                        .where('swapPartnerProperty', isEqualTo: _myProperty.id)
                        .get()
                        .then((filteredAcceptedProperty) =>
                            filteredAcceptedProperty.docs
                                .forEach((accProperty) {
                              accProperty.reference.delete();
                            }));
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  )),
            ],
          ),
          subtitle: Text(
              "Date Range: ${DateFormat.yMd().format(widget.request.data()['selectedStartDate'].toDate())} - ${DateFormat.yMd().format(widget.request.data()['selectedEndDate'].toDate())}\nTap on this request to view the requestor's space."),
        ),
      );
    // return Column(
    //   children: [
    //     Text(widget.request.data()['myProperty']),
    //     Text(_myProperty.data()['title']),
    //     Text(widget.request.data()['swapPartnerProperty']),
    //     Text(_swapPartnerProperty.data()['title']),
    //   ],
    // );
    return Center(
      child: CircularProgressIndicator(
          // color: kPrimaryColor,
          // size: 50.0,
          ),
    );
  }
}
