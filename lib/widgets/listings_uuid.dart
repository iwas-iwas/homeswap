import 'package:conspacesapp/widgets/listings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../credentials.dart';
import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import '../widgets/listings_uuid.dart';
import 'package:intl/intl.dart';
import './property_style.dart';
import 'package:auto_size_text/auto_size_text.dart';

const kGoogleApiKey = PLACES_API_KEY;

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class ListingsUnique extends StatefulWidget {
  @override
  _ListingsUniqueState createState() => _ListingsUniqueState();
}

class _ListingsUniqueState extends State<ListingsUnique> {
  String _pickedLocation = '';
  String _pickedDestination = '';
  String _pickedFullDestination = '';
  final _titleController = TextEditingController();
  var _enteredMessage;
  File _storedImage;
  DateTimeRange _selectedDate;
  bool _isButtonDisabled = false;
  bool _noDestination = false;

  File _firstAdditionalImage;
  File _secondAdditionalImage;

  @override
  void initState() {
    _isButtonDisabled = false;
    super.initState();
  }

  Future<int> checkIfActive(String currentUserId, String propertyId) async {
    //String swapPartnerId = '';

    QuerySnapshot receivedActiveSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('requests')
        .where("status", isEqualTo: "accepted")
        .where("type", isEqualTo: "received")
        .where('myProperty', isEqualTo: propertyId)
        .get();

    print('alreadyActiveReceived: ${receivedActiveSnapshot.docs.length}');

    int alreadyActiveReceived = receivedActiveSnapshot.docs.length;

    QuerySnapshot sendActiveSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('requests')
        .where("status", isEqualTo: "accepted")
        .where("type", isEqualTo: "send")
        .where('RequestSendByProperty', isEqualTo: propertyId)
        .get();

    print('alreadyActiveSend: ${sendActiveSnapshot.docs.length}');

    int alreadyActiveSend = sendActiveSnapshot.docs.length;

    if (alreadyActiveReceived > 0 || alreadyActiveSend > 0) {
      return 1;
    } else {
      return 0;
    }
  }

  showAlertDialog(BuildContext context, String propertyId, String currentUserId,
      _scaffoldKey) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop();
        //_deleteProperty(propertyId);
        checkIfActive(currentUserId, propertyId)
            .then((currentlyActiveProperty) {
          if (currentlyActiveProperty == 1) {
            SnackBar snackBar = SnackBar(
              content: Container(
                height: 100,
                color: Color(0xFF4845c7),
                child: Text(
                  'Failed to Delete Property. It is currently in an active Swap.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              backgroundColor: Colors.black,
            );
            _scaffoldKey.currentState.showSnackBar(snackBar);
          } else {
            _deleteProperty(propertyId);
          }

          Navigator.of(context).pop();
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Property"),
      content: Text("Are you sure you want to delete the Property?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _deleteProperty(String propertyId) {
    FocusScope.of(context).unfocus();
    _isButtonDisabled = true;

    FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId)
        .delete();
  }

  void _sendMessage(String propertyId) async {
    FocusScope.of(context).unfocus();
    _isButtonDisabled = true;
    Navigator.pop(context);
    _isButtonDisabled = false;
    // close keyboard
    // FocusScope.of(context).unfocus();
    // _isButtonDisabled = true;
    // grab the curren user
    final user = FirebaseAuth.instance.currentUser;
    // use current user to grab the uid and fetch user data (e.g. username)
    // final userData = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(user.uid)
    //     .get();

    dynamic updatedUrl;
    String updatedDestination = '';
    String updatedTitle;
    String updatedFirstUrl = '';
    String updatedSecondUrl = '';
    String updatedFullDestinationAddress = '';

    if (_storedImage != null) {
      // Get Image Url
      final ref = FirebaseStorage.instance
          .ref()
          .child('property_images')
          .child(user.uid)
          .child(user.uid + Timestamp.now().toString() + '.jpg');

      // here we get the image reference (url) from the image file and set it in the user document
      await ref.putFile(_storedImage).onComplete;

      updatedUrl = await ref.getDownloadURL();
    }

    if (_firstAdditionalImage != null) {
      // Get Image Url
      final ref = FirebaseStorage.instance
          .ref()
          .child('property_images')
          .child(user.uid)
          .child(user.uid + Timestamp.now().toString() + '_1' + '.jpg');

      // here we get the image reference (url) from the image file and set it in the user document
      await ref.putFile(_firstAdditionalImage).onComplete;

      updatedFirstUrl = await ref.getDownloadURL();
    }

    if (_secondAdditionalImage != null) {
      // Get Image Url
      final ref = FirebaseStorage.instance
          .ref()
          .child('property_images')
          .child(user.uid)
          .child(user.uid + Timestamp.now().toString() + '_2' + '.jpg');

      // here we get the image reference (url) from the image file and set it in the user document
      await ref.putFile(_secondAdditionalImage).onComplete;

      updatedSecondUrl = await ref.getDownloadURL();
    }

    if (_noDestination != null ||
        (_pickedDestination != '' && _pickedDestination != null)) {
      updatedDestination = _noDestination ? 'ffa' : _pickedDestination;
      updatedFullDestinationAddress =
          _noDestination ? 'ffa' : _pickedFullDestination;
    }

    if (_enteredMessage != null) {
      updatedTitle = _enteredMessage;
    }

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('properties').doc(propertyId);

    if (updatedTitle != null &&
        updatedDestination.length > 2 &&
        updatedUrl != null) {
      documentReference.update({
        //'id': documentReference.id,
        'title': updatedTitle,
        'userImage': updatedUrl,
        'destination': updatedDestination,
        'fullDestinationAddress': updatedFullDestinationAddress
      });
    }

    if (updatedTitle != null &&
        updatedDestination.length > 2 &&
        updatedUrl == null) {
      documentReference.update({
        'title': updatedTitle,
        'destination': updatedDestination,
        'fullDestinationAddress': updatedFullDestinationAddress
      });
    }

    if (updatedTitle != null &&
        updatedUrl != null &&
        updatedDestination.length == 0) {
      documentReference.update({
        'title': updatedTitle,
        'userImage': updatedUrl,
      });
    }

    if (updatedTitle != null &&
        updatedDestination.length == 0 &&
        updatedUrl == null) {
      documentReference.update({
        'title': updatedTitle,
      });
    }

    if (updatedDestination.length > 2 &&
        updatedUrl != null &&
        updatedTitle == null) {
      documentReference.update({
        'userImage': updatedUrl,
        'destination': updatedDestination,
        'fullDestinationAddress': updatedFullDestinationAddress
      });
    }

    if (updatedDestination.length > 2 &&
        updatedTitle == null &&
        updatedUrl == null) {
      documentReference.update({
        'destination': updatedDestination,
        'fullDestinationAddress': updatedFullDestinationAddress
      });
    }

    if (updatedUrl != null &&
        updatedDestination.length == 0 &&
        updatedTitle == null) {
      documentReference.update({
        'userImage': updatedUrl,
      });
    }

    if (updatedFirstUrl != "") {
      documentReference.update({
        'firstAdditionalImage': updatedFirstUrl,
      });
    }

    if (updatedSecondUrl != "") {
      documentReference.update({
        'secondAdditionalImage': updatedSecondUrl,
      });
    }

    // clear message in textfield after onpressed is done
    // _titleController.clear();
    // Navigator.pop(context);
    // _isButtonDisabled = false;

    setState(() {
      // clear message in textfield after onpressed is done
      _titleController.clear();
      _pickedLocation = '';
      _pickedDestination = '';
      _storedImage = null;
      _firstAdditionalImage = null;
      _secondAdditionalImage = null;
      _noDestination = false;
      // Navigator.pop(context);
    });
  }

  void _startEditProperty(
    BuildContext ctx,
    String currentDestination,
    String propertyId,
    String currentUserId,
    _scaffoldKey,
    String currentMainImage,
    String currentFirstAdditionalImage,
    String currentSecondAdditionalImage,
    Size size,
  ) {
    if (currentDestination == 'ffa') {
      currentDestination = 'Free for all';
    }
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter modalState /*You can rename this!*/) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RaisedButton.icon(
                  onPressed: () {
                    showAlertDialog(
                        context, propertyId, currentUserId, _scaffoldKey);
                    //_deleteProperty(propertyId);
                  },
                  icon: Icon(Icons.delete_outline, color: Colors.black),
                  label: Text(
                    'Delete Property',
                    style: TextStyle(color: Colors.black),
                  ),
                  color: Colors.white,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 25),
                          Text(
                            'Enter New Title',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          TextField(
                              decoration: InputDecoration(labelText: 'title'),
                              controller: _titleController,
                              onChanged: (value) {
                                modalState(() {
                                  if (_titleController.text.isEmpty) {
                                    print('text not valid.');
                                  } else {
                                    _enteredMessage = value;
                                  }
                                });
                              }),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            'Enter New Destination',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _noDestination == true
                                  ? Text('Free for all')
                                  : AutoSizeText(
                                      (_pickedDestination != '' &&
                                              _pickedDestination != null &&
                                              _pickedFullDestination != '')
                                          ? _pickedFullDestination
                                          : (currentDestination != null &&
                                                  currentDestination != '')
                                              ? currentDestination
                                              : 'No Destination Selected',
                                      maxLines: 2),
                              SizedBox(width: 10),
                              InkWell(
                                child: Text(
                                  'Select new Destination',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                onTap: () async {
                                  Prediction p = await PlacesAutocomplete.show(
                                      context: context, apiKey: kGoogleApiKey);
                                  final destinationData =
                                      displayPrediction(p).then((location) {
                                    modalState(() {
                                      _pickedDestination = location[0];
                                      _pickedFullDestination = location[1];
                                      if (currentDestination ==
                                              'Free for all' &&
                                          location != null) {
                                        _noDestination = false;
                                        currentDestination = '';
                                      }
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Free for all Destinations: '),
                              Checkbox(
                                value: currentDestination == 'Free for all'
                                    ? true
                                    : _noDestination,
                                onChanged: (bool value) {
                                  modalState(() {
                                    _noDestination = value;
                                    if (value == false &&
                                        currentDestination == 'Free for all') {
                                      currentDestination = '';
                                    }

                                    if (value == true) {
                                      currentDestination = 'Free for all';
                                      //currentDestination == '';
                                      _pickedDestination = '';
                                    }
                                    // if (value == true &&
                                    //     currentDestination == '') {
                                    //   currentDestination = 'Free for all';
                                    //   if (_pickedDestination != null &&
                                    //       _pickedDestination != '') {
                                    //     _pickedDestination = '';
                                    //   }
                                    // }
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Upload New Main Image',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                //width: 150,
                                width: size.width * 0.3,
                                height: 100,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                ),
                                // wenn image geupdated wurde, zeige das neue, ansonsten, wenn ein altes/aktuelles exisitiert zeige das, wenn das nicht existiert, zeige "No image Taken"
                                child: _storedImage != null
                                    ? Image.file(
                                        _storedImage,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : currentMainImage != null
                                        ? Image.network(
                                            currentMainImage,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : Text(
                                            'No Image Taken',
                                            textAlign: TextAlign.center,
                                          ),
                                alignment: Alignment.center,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: FlatButton.icon(
                                  icon: Icon(Icons.camera),
                                  label: Text('Take Picture'),
                                  textColor: Theme.of(context).primaryColor,
                                  onPressed: () => _takePicture(modalState),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Upload New Additional Pictures',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                //width: 150,
                                width: size.width * 0.3,
                                height: 100,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                ),
                                child: _firstAdditionalImage != null
                                    ? Image.file(
                                        _firstAdditionalImage,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : currentFirstAdditionalImage != null
                                        ? Image.network(
                                            currentFirstAdditionalImage,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : Text(
                                            'No Image Taken',
                                            textAlign: TextAlign.center,
                                          ),
                                alignment: Alignment.center,
                              ),
                              SizedBox(width: size.width * 0.05),
                              Expanded(
                                child: FlatButton.icon(
                                  icon: Icon(Icons.camera),
                                  label: Text('Take Picture'),
                                  textColor: Theme.of(context).primaryColor,
                                  onPressed: () =>
                                      _takeFirstAdditionalPicture(modalState),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: size.width * 0.05),
                          Row(
                            children: [
                              Container(
                                // width: 150,
                                width: size.width * 0.3,
                                height: 100,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                ),
                                child: _secondAdditionalImage != null
                                    ? Image.file(
                                        _secondAdditionalImage,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : currentSecondAdditionalImage != null
                                        ? Image.network(
                                            currentSecondAdditionalImage,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : Text(
                                            'No Image Taken',
                                            textAlign: TextAlign.center,
                                          ),
                                alignment: Alignment.center,
                              ),
                              SizedBox(width: size.width * 0.05),
                              Expanded(
                                child: FlatButton.icon(
                                  icon: Icon(Icons.camera),
                                  label: Text('Take Picture'),
                                  textColor: Theme.of(context).primaryColor,
                                  onPressed: () =>
                                      _takeSecondAdditionalPicture(modalState),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Color(0xFF4845c7),
                  child: SafeArea(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Update Property'),
                      onPressed: !_isButtonDisabled
                          ? () => _sendMessage(propertyId)
                          : null,
                      elevation: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      color: Color(0xFF4845c7),
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

  Future<void> _takePicture(modalState) async {
    // THis is the new version of imagepicker. switch the user image to it if needed.
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
      //source: ImageSource.camera,
      source: ImageSource.camera,
      maxWidth: 600,
    );
    modalState(() {
      _storedImage = File(imageFile.path);
    });
  }

  Future<void> _takeFirstAdditionalPicture(modalState) async {
    // THis is the new version of imagepicker. switch the user image to it if needed.
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
      //source: ImageSource.camera,
      source: ImageSource.camera,
      maxWidth: 600,
    );
    modalState(() {
      _firstAdditionalImage = File(imageFile.path);
    });
  }

  Future<void> _takeSecondAdditionalPicture(modalState) async {
    // THis is the new version of imagepicker. switch the user image to it if needed.
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
      //source: ImageSource.camera,
      source: ImageSource.camera,
      maxWidth: 600,
    );
    modalState(() {
      _secondAdditionalImage = File(imageFile.path);
    });
  }

  void _presentDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2020, 12, 31),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: ListView(
          //scrollDirection: Axis.vertical,
          //crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: AutoSizeText(
                "Personal Listings",
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                maxLines: 1,
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('properties')
                    .where('userId', isEqualTo: user.uid)
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

                  if (documents.length == 0) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, top: 25),
                      child: Text(
                          'You are almost ready to go! To be able to swap, you just have to list a space of yours. Press the Plus button to start adding a space.'),
                    );
                  } else {
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
                      itemBuilder: (ctx, index) => Stack(
                        children: [
                          PropertyStyle(
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
                            true,
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
                            documents[index].data()['userMail'],
                            key: ValueKey(documents[index].id),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4845c7),
                                  shape: BoxShape.circle,
                                ),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (_isButtonDisabled == true) {
                                          _isButtonDisabled = false;
                                        }

                                        _startEditProperty(
                                          context,
                                          _pickedDestination != ''
                                              ? _pickedDestination
                                              : documents[index].data()[
                                                  'fullDestinationAddress'],
                                          documents[index].id,
                                          user.uid,
                                          _scaffoldKey,
                                          documents[index].data()['userImage'],
                                          documents[index]
                                              .data()['firstAdditionalImage'],
                                          documents[index]
                                              .data()['secondAdditionalImage'],
                                          size,
                                        );
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}

Future<List<dynamic>> displayPrediction(Prediction p) async {
  if (p != null) {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);

    var placeId = p.placeId;
    double lat = detail.result.geometry.location.lat;
    double lng = detail.result.geometry.location.lng;
    String street = detail.result.geometry.location.toString();
    String loc = detail.result.formattedAddress.toString();

    var address = await Geocoder.google(kGoogleApiKey)
        .findAddressesFromQuery(p.description);

    return [address.first.locality, address.first.addressLine];
    //return address.first.addressLne;
  }
}
