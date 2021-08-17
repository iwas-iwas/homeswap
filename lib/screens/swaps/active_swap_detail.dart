import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conspacesapp/widgets/property_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveRequest extends StatefulWidget {
  ActiveRequest(this.request, this.currentUserId);

  final dynamic request;
  final String currentUserId;

  @override
  _ActiveRequestState createState() => _ActiveRequestState();
}

class _ActiveRequestState extends State<ActiveRequest> {
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
                    _swapPartnerProperty.data()['locationFullPlaceId'],
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
                          text:
                              "${_swapPartnerProperty.data()['username']}'s Space: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: _swapPartnerProperty.data()['title'],
                      ),
                    ],
                  ),
                ),
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
                          text: 'Your Space: ',
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
          // trailing: Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     Icon(Icons.check_box, color: Colors.greenAccent),
          //     SizedBox(width: 20),
          //     Icon(Icons.delete, color: Colors.redAccent),
          //   ],
          // ),
          subtitle: Text(
              "Date Range: ${DateFormat.yMd().format(widget.request.data()['selectedStartDate'].toDate())} - ${DateFormat.yMd().format(widget.request.data()['selectedEndDate'].toDate())}\nTap on this request to view the space from ${_swapPartnerProperty.data()['username']}. The exact location can now also be found there."),
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
