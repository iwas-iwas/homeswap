import 'package:conspacesapp/credentials.dart';
import 'package:conspacesapp/screens/detail_screen.dart';
import 'package:conspacesapp/widgets/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../widgets/helper/location_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_webservice/places.dart';

class Detail extends StatefulWidget {
  Detail(
      this.propertyTitle,
      this.userName,
      this.userImage,
      this.propertyLocation,
      this.propertyUserId,
      this.currentUserId,
      this.propertyId,
      this.fromSwapsorListingsUnique,
      this.bathrooms,
      this.bedrooms,
      this.kitchen,
      this.workspaces,
      this.sqm,
      this.firstAdditionalImage,
      this.secondAdditionalImage,
      this.isMe,
      this.userProfileImage,
      this.userMail,
      this.fromActive,
      this.fromListingsUniqueId,
      this.fromListingsUnique,
      {this.key});

  final Key key;

  final String propertyTitle;
  final String userName;
  final String userImage;
  final String propertyLocation;
  final String propertyUserId;
  final String currentUserId;
  final String propertyId;
  final bool fromSwapsorListingsUnique;
  // final double latitude;
  // final double longitude;
  final double bathrooms;
  final double bedrooms;
  final double kitchen;
  final double workspaces;
  final double sqm;
  final String firstAdditionalImage;
  final String secondAdditionalImage;
  final bool isMe;
  final String userProfileImage;
  final String userMail;
  final String fromActive; // full location address from active swaps
  final String fromListingsUniqueId; // full location address from listings_uuid
  final bool fromListingsUnique;

  //final GlobalKey<ScaffoldState> scaffoldKey;
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: QUERY4);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  List<String> _tag = ['imageHero', 'imageHero2', 'imageHero3'];

  String _selectedProperty = '';
  DateTimeRange _selectedDate;
  bool _isLoading = false;
  bool _isPremium = true;
  bool _atleastOneSpace = false;
  String _location = '';
  String _fullLocation = '';
  double _lat;
  double _long;

  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    //bool isPremium = false;
    bool isPremium = true;
    bool atleastOneSpace = false;
    PlacesDetailsResponse detail =
        await widget._places.getDetailsByPlaceId(widget.fromListingsUniqueId);

    var addressInitial = detail.result.formattedAddress;

    var address =
        await Geocoder.google(KEY).findAddressesFromQuery(addressInitial);

    double lat = detail.result.geometry.location.lat;
    double lng = detail.result.geometry.location.lng;

    // only need to check if greater one listing if premium user. otherwise premium required will be shown anyway.
    if (isPremium) {
      QuerySnapshot atleastOneQuery = await FirebaseFirestore.instance
          .collection('properties')
          .where('userId', isEqualTo: widget.currentUserId)
          .get();

      if (atleastOneQuery.docs.isNotEmpty) {
        atleastOneSpace = true;
      }
    }

    setState(() {
      _location = address.first.locality;
      _fullLocation = address.first.addressLine;
      _lat = lat;
      _long = lng;
      _atleastOneSpace = atleastOneSpace;
    });
  }

  void _presentDatePicker(modalState) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2020, 12, 31),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      modalState(() {
        _selectedDate = pickedDate;
      });
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

  Future<int> dateRangeAvailabilityCheck(
      currentUserId, selectedDate, requestSendToThisUser) async {
    // check if current user has active overlap
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('requests')
        .where("status", isEqualTo: "accepted")
        .where("selectedStartDate",
            isLessThanOrEqualTo: selectedDate.end) // StartA <= EndB
        .get();

    List<Timestamp> selectedEndDates = [];

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      selectedEndDates.add(a.data()['selectedEndDate']);
    }

    bool unavailable = checkOverlap(selectedEndDates, selectedDate.start);

    // check if receiving has active overlap

    QuerySnapshot querySnapshotTwo = await FirebaseFirestore.instance
        .collection('users')
        .doc(requestSendToThisUser)
        .collection('requests')
        .where("status", isEqualTo: "accepted")
        .where("selectedStartDate",
            isLessThanOrEqualTo: selectedDate.end) // StartA <= EndB
        .get();

    List<Timestamp> selectedEndDatesTwo = [];

    for (int i = 0; i < querySnapshotTwo.docs.length; i++) {
      var aTwo = querySnapshotTwo.docs[i];
      // mit der ID kann ich theoreisch fromDoc callen
      // print(a.id);
      // print(a.data()['selectedStartDate']);
      selectedEndDatesTwo.add(aTwo.data()['selectedEndDate']);
    }

    bool unavailable2 = checkOverlap(selectedEndDatesTwo, selectedDate.start);

    print(unavailable2);

    // if date overlap, stop right there and dont allow the request. show snackbar. else,  check if too many send request.
    if (unavailable == true || unavailable2 == true) {
      return 2;
    }

    // already pending or active
    QuerySnapshot alreadySendRequestToUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('requests')
        .where('RequestSendToUser', isEqualTo: requestSendToThisUser)
        .get();

    // if date overlap and not too many send requests check if the user already send a request to the user (need to check received aswell prbly)
    if (alreadySendRequestToUser.docs.isNotEmpty) {
      return 0;
    }

    return 3;
  }

  sendRequestFirebase(dynamic propertyUserId, dynamic currentUserId,
      dynamic propertyId, selectedDate, globalKey, modalState) {
    modalState(() {
      _isLoading = true;
    });
    dateRangeAvailabilityCheck(currentUserId, selectedDate, propertyUserId)
        .then((unavailable) async {
      if (unavailable == 2) {
        SnackBar snackBar = swapRequestSnackbar(
            'Failed to send Request. There is an overlap with your desired period and an active swap by you or the swap partner.');
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();

        globalKey.currentState.showSnackBar(snackBar);
      } else if (unavailable == 0) {
        SnackBar snackBar = swapRequestSnackbar(
            "Request could not be sent. You cannot have multiple pending or active requests with the same user.");
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();

        globalKey.currentState.showSnackBar(snackBar);
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(propertyUserId) // user id of request receiverr
            .collection('requests')
            .add({
          'type': 'received',
          'RequestSendToUser': currentUserId,
          'swapPartnerProperty': _selectedProperty, // SWAPPARTNER Property
          'myProperty': propertyId, // MYPROPERTY
          'propertyId': _selectedProperty,
          'selectedStartDate': selectedDate.start,
          'selectedEndDate': selectedDate.end,
          'createdAt': Timestamp.now(),
          'status': 'pending',
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId) // user id of request sender (current user)
            .collection('requests')
            .add({
          'type': 'send',
          'requestedBy': currentUserId,
          'RequestSendToProperty': propertyId,
          'myProperty': _selectedProperty, // MYPROPERTY
          'swapPartnerProperty': propertyId, // SWAPPARTNER Property
          'RequestSendToUser': propertyUserId,
          'selectedStartDate': selectedDate.start,
          'selectedEndDate': selectedDate.end,
          'createdAt': Timestamp.now(),
          'status': 'pending',
        });
        SnackBar snackBar = SnackBar(
          content: Text(
            'Swap Request has been send.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF4845c7),
        );
        modalState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();

        globalKey.currentState.showSnackBar(snackBar);
      }
      // Navigator.of(context).pop();

      // globalKey.currentState.showSnackBar(snackBar);
    });
  }

  void triggerSwapRequest(BuildContext ctx, currentUser, propertyUserId,
      currentUserId, propertyId, scaffoldKey) {
    //popertyID is the property the current user wants to make a swap request with
    showModalBottomSheet(
        context: context,
        builder: (context) {
          print(propertyId);
          return StatefulBuilder(
            builder: (BuildContext context,
                StateSetter modalState /*You can rename this!*/) {
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('properties')
                      .where('userId', isEqualTo: currentUser.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  // whenever the properties collection receives a new value, the function inside of the builder argument is executed
                  builder: (ctx, streamSnapshot) {
                    if (streamSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!streamSnapshot.hasData) {
                      return Text('Loading');
                    }
                    final documents = streamSnapshot.data.docs;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Swap Request',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          //padding: const EdgeInsets.only(left: 8.0),
                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                          child: Text(
                            'Select a Property',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          height: 120,
                          child: ListView.builder(
                            //reverse: true,
                            itemCount: documents.length,
                            itemBuilder: (ctx, index) => ListTile(
                              title: Text(
                                  //"${documents[index].data()['title']}, ${documents[index].data()['_location']}"),
                                  "${documents[index].data()['title']}"),
                              leading: Radio(
                                value: documents[index].id,
                                groupValue: _selectedProperty,
                                onChanged: (selectedProperty) {
                                  modalState(() {
                                    // property the current user wishes to offer for swap request
                                    _selectedProperty = selectedProperty;
                                  });
                                },
                              ),
                            ),
                            // ),
                          ),
                        ),
                        //   ],
                        // ),
                        //),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Select a Date Range',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(_selectedDate == null
                                  ? 'No Date Chosen!'
                                  //: {$('DateFormat.yMd(_selectedDate.start))')},
                                  : '${DateFormat.yMd().format(_selectedDate.start)} - ${DateFormat.yMd().format(_selectedDate.end)}'),
                            ),
                            FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'Choose Date',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              onPressed: () => _presentDatePicker(modalState),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (_isLoading)
                          Center(child: CircularProgressIndicator()),
                        if (!_isLoading)
                          Container(
                            color: Color(0xFF4845c7),
                            child: SafeArea(
                              child: RaisedButton.icon(
                                icon: Icon(Icons.add),
                                color: Color(0xFF4845c7),
                                label: Text('Submit Request'),
                                elevation: 0,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onPressed: () {
                                  if (_selectedProperty != '' &&
                                      _selectedDate != null &&
                                      !_isLoading) {
                                    // && isloading false?

                                    sendRequestFirebase(
                                        propertyUserId,
                                        currentUserId,
                                        propertyId,
                                        //_selectedDate.toString())
                                        _selectedDate,
                                        scaffoldKey,
                                        modalState);
                                  }

                                  //: null;
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  });
            },
          );
        });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    if (_isPremium != null &&
        _location != '' &&
        _fullLocation != '' &&
        _lat != null &&
        _long != null)
      return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 0, bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: size.height * 0.9,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView(shrinkWrap: false, children: [
                        Padding(
                          // padding: EdgeInsets.all(
                          //   24,
                          padding: EdgeInsets.only(
                              left: 24, right: 24, top: 0, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    widget.userProfileImage == null
                                        ? Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/profile_default.jpg"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: widget.userProfileImage,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              width: 65.0,
                                              height: 65.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            placeholder: (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: size.width * 0.3,
                                            child: Text(
                                              widget.userName,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            "Conspaces User",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4845c7).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          if (widget
                                                  .fromSwapsorListingsUnique ||
                                              widget.isMe ||
                                              !_isPremium ||
                                              !_atleastOneSpace) {
                                            SnackBar failSnackBar = SnackBar(
                                              content: Text(
                                                !_isPremium
                                                    ? 'Sending swap requests requires a premium account.'
                                                    : !_atleastOneSpace
                                                        ? 'You need at least one listed space to send a swap request.'
                                                        : widget.fromSwapsorListingsUnique
                                                            ? 'Failed to send request. You can only send swap requests from the explore page.'
                                                            : widget.isMe
                                                                ? 'You cant swap your own spaces.'
                                                                : 'Failed to send request.',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor:
                                                  Color(0xFF4845c7),
                                            );

                                            _scaffoldKey.currentState
                                                .showSnackBar(failSnackBar);
                                          } else {
                                            triggerSwapRequest(
                                                context,
                                                user,
                                                widget.propertyUserId,
                                                widget.currentUserId,
                                                widget.propertyId,
                                                _scaffoldKey);
                                          }
                                        },
                                        child: Icon(
                                          Icons.swap_horiz,
                                          color: Color(0xFF4845c7),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4845c7).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (widget.isMe || !_isPremium) {
                                            SnackBar failSnackBar = SnackBar(
                                              content: Text(
                                                !_isPremium
                                                    ? 'Sending emails to other users requires a premium account.'
                                                    : widget.isMe
                                                        ? 'You can not send yourself an email.'
                                                        : 'Failed to open email.',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor:
                                                  Color(0xFF4845c7),
                                            );

                                            _scaffoldKey.currentState
                                                .showSnackBar(failSnackBar);
                                          } else {
                                            Utils.openEmail(
                                              toEmail: widget.userMail,
                                              subject: 'Email Subject',
                                              body: 'Email Body',
                                            );
                                          }
                                        },
                                        child: Icon(
                                          Icons.mail,
                                          color: Color(0xFF4845c7),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 24,
                            left: 24,
                            bottom: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildFeature(Icons.desktop_mac,
                                  "${widget.workspaces.round()} Spaces"),
                              buildFeature(Icons.hotel,
                                  "${widget.bedrooms.round()} Bedrooms"),
                              buildFeature(Icons.people,
                                  "${widget.kitchen.round()} Roommates"),
                              buildFeature(Icons.wc,
                                  "${widget.bathrooms.round()} Bathrooms"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 24, left: 24, bottom: 24),
                          child: Text("Location",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                              right: 24,
                              left: 24,
                              bottom: 16,
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                      LocationHelper
                                          .generateLocationPreviewImage(
                                              latitude: _lat, longitude: _long),
                                      fit: BoxFit.cover,
                                      width: double.infinity),
                                ),
                                SizedBox(height: 5),
                                Text(widget.fromActive != ''
                                    ? "Location: $_fullLocation"
                                    : widget.fromListingsUnique
                                        ? "Location: $_fullLocation.\nOther users can only see the exact location when they have an active swap with your space."
                                        : 'The exact location will be displayed under your active swap summary once you have both decided to swap.'),
                                // Text(widget.fromActive == ''
                                //     ? 'The exact location will be displayed under your active swap summary once you have both decided to swap.' : widget.fromActive != '' ? widget.fromActive : 'lol'),
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 24, left: 24, bottom: 24),
                          child: Text("Pictures",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 24,
                                  ),
                                  child: ListView(
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    // listview children takes list of widgets (images in this case)
                                    children: buildPhotos([
                                      widget.userImage,
                                      widget.firstAdditionalImage,
                                      widget.secondAdditionalImage
                                    ], context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),

        //),
      );
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SpinKitRotatingCircle(
            color: kPrimaryColor,
            size: 50.0,
          ),
        ));
  }

  Widget buildFeature(IconData iconData, String text) {
    return Column(
      children: [
        Icon(
          iconData,
          color: Color(0xFF4845c7),
          size: 28,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        )
      ],
    );
  }
}

SnackBar swapRequestSnackbar(String message) {
  return SnackBar(
    content: Text(
      message != null ? message : 'Failed to send request.',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Color(0xFF4845c7),
  );
}

List<Widget> buildPhotos(List<String> images, context) {
  List<Widget> list = [];

  list.add(SizedBox(width: 24));
  // iteriere ueber imags einer property und uebergib buildpohto die jeweilige url und den iteration-index
  for (var i = 0; i < images.length; i++) {
    if (images[i] != null) {
      list.add(buildPhoto(images[i], i, context));
    }
  }
  return list;
}

buildPhoto(String url, int index, context) {
  var _tag = ['imageHero', 'imageHero2', 'imageHero3'];

  return AspectRatio(
    aspectRatio: 3 / 2,
    child: GestureDetector(
        child: Container(
          margin: EdgeInsets.only(right: 24),
          child: Hero(
            tag: _tag[index],
            child: CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, url) => Center(
                  child: Container(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => Icon(Icons.error),
              imageBuilder: (context, imageProvider) => Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return DetailScreen(tag: _tag[0], url: url);
          }));
        }),
  );
}
