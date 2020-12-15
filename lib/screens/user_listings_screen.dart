import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../constants.dart';
import '../credentials.dart';
import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import '../widgets/listings_uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'auth_screen.dart';

const kGoogleApiKey = PLACES_API_KEY;

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class UserListingsScreen extends StatefulWidget {
  @override
  _UserListingsScreenState createState() => _UserListingsScreenState();
}

class _UserListingsScreenState extends State<UserListingsScreen> {
  String _pickedLocation = '';
  double _pickedLongitude;
  double _pickedLatitude;
  String _pickedDestination = '';
  final _titleController = TextEditingController();
  var _enteredMessage;
  File _storedImage;
  File _firstAdditionalImage;
  File _secondAdditionalImage;

  DateTimeRange _selectedDate;

  bool _isButtonDisabled = false;
  bool _noDestination = false;
  bool _wifi = true;

  double _bedroomCount = 0;
  final _bedroomController = TextEditingController();
  bool _bedroomValidator = false;

  double _workspaceCount = 0;
  final _workspaceController = TextEditingController();
  bool _workspaceValidator = false;

  double _bathroomCount = 0;
  final _bathroomController = TextEditingController();
  bool _bathroomValidator = false;

  double _kitchenCount = 0;
  final _kitchenController = TextEditingController();
  bool _kitchenValidator = false;

  double _sqm = 0;
  final _sqmController = TextEditingController();
  bool _sqmValidator = false;

  bool _isLoading = false;

  bool _isAnon = false;

  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user.isAnonymous) {
      setState(() {
        _isAnon = true;
      });
    } else {
      _isButtonDisabled = false;
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _isButtonDisabled = false;
  // }

  void _sendMessage(modalState) async {
    modalState(() {
      _isLoading = true;
    });
    String firstAdditionalImageUrl = '';
    String secondAdditionalImageUrl = '';
    // close keyboard
    FocusScope.of(context).unfocus();
    _isButtonDisabled = true;
    // Navigator.pop(context);
    _isButtonDisabled = false;

    // grab the curren user
    final user = FirebaseAuth.instance.currentUser;
    // use current user to grab the uid and fetch user data (e.g. username)
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    // Get Image Url
    final ref = FirebaseStorage.instance
        .ref()
        .child('property_images')
        .child(user.uid + Timestamp.now().toString() + '.jpg');

    String _destination = _noDestination ? 'ffa' : _pickedDestination;

    // here we get the image reference (url) from the image file and set it in the user document
    await ref.putFile(_storedImage).onComplete;

    final url = await ref.getDownloadURL();
    print('entered message: $_enteredMessage');
    print('url: $url');

    if (_firstAdditionalImage != null) {
      // Get Image Url
      final ref = FirebaseStorage.instance
          .ref()
          .child('property_images')
          .child(user.uid + Timestamp.now().toString() + "_1" + '.jpg');

      await ref.putFile(_firstAdditionalImage).onComplete;

      firstAdditionalImageUrl = await ref.getDownloadURL();
    }

    if (_secondAdditionalImage != null) {
      // Get Image Url
      final ref = FirebaseStorage.instance
          .ref()
          .child('property_images')
          .child(user.uid + Timestamp.now().toString() + "_2" + '.jpg');

      await ref.putFile(_secondAdditionalImage).onComplete;

      secondAdditionalImageUrl = await ref.getDownloadURL();
    }

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('properties').doc();
    documentReference.set({
      'id': documentReference.id,
      'title': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      // for every new property, the username of the creator is stored
      'username': userData.data()['username'],
      'userProfileImage': userData.data()['image_url'],
      'userMail': userData.data()['email'],
      'userImage': url,
      'location': _pickedLocation,
      'longitude': _pickedLongitude,
      'latitude': _pickedLatitude,
      //'destination': _pickedDestination,
      //'noDestination': _noDestination
      'destination': _destination,
      'bedrooms': _bedroomCount,
      'workspaces': _workspaceCount,
      'kitchen': _kitchenCount,
      'bathrooms': _bathroomCount,
      'sqm': _sqm,
      'firstAdditionalImage':
          firstAdditionalImageUrl != '' ? firstAdditionalImageUrl : null,
      'secondAdditionalImage':
          secondAdditionalImageUrl != '' ? secondAdditionalImageUrl : null,
      //'userImage': userData.data()['image_url']
    });

    setState(() {
      // clear message in textfield after onpressed is done
      _titleController.clear();
      _bathroomController.clear();
      _kitchenController.clear();
      _bedroomController.clear();
      _workspaceController.clear();
      _sqmController.clear();
      _pickedLocation = '';
      _pickedDestination = '';
      _storedImage = null;
      _firstAdditionalImage = null;
      _secondAdditionalImage = null;
      _noDestination = false;
      // Navigator.pop(context);
      _isLoading = false;
      _isButtonDisabled = false;
    });
    Navigator.pop(context);
    //_isButtonDisabled = false;
  }

  void _startAddNewProperty(BuildContext ctx, Size size) {
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Scaffold(
            key: _scaffoldKey,
            body: StatefulBuilder(builder: (BuildContext context,
                StateSetter modalState /*You can rename this!*/) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Title',
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
                            SizedBox(height: 30),
                            Text(
                              'Enter Location',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((_pickedLocation != '' &&
                                        _pickedLocation != null)
                                    ? _pickedLocation
                                    : 'No Location Chosen'),
                                SizedBox(width: 10),
                                InkWell(
                                  child: Text(
                                    'Choose Location',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  onTap: () async {
                                    Prediction p =
                                        await PlacesAutocomplete.show(
                                            context: context,
                                            apiKey: kGoogleApiKey);
                                    final locationData =
                                        displayPrediction(p).then((location) {
                                      modalState(() {
                                        _pickedLocation = location[0];
                                        _pickedLatitude = location[1];
                                        _pickedLongitude = location[2];
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Enter Destination',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _noDestination == true
                                    ? Text('Free for all')
                                    : Text((_pickedDestination != '' &&
                                            _pickedDestination != null)
                                        ? _pickedDestination
                                        : 'No Destination Chosen'),
                                SizedBox(width: 10),
                                InkWell(
                                  child: Text(
                                    'Choose Destination',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  onTap: () async {
                                    Prediction p =
                                        await PlacesAutocomplete.show(
                                            context: context,
                                            apiKey: kGoogleApiKey);
                                    final destinationData =
                                        displayPrediction(p).then((location) {
                                      modalState(() {
                                        _pickedDestination = location[0];
                                        // _pickedLatitude = location[1];
                                        // _pickedLongitude = location[2];
                                        if (_noDestination == true &&
                                            location != null) {
                                          _noDestination = false;
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
                                  value: _noDestination,
                                  onChanged: (bool value) {
                                    modalState(() {
                                      _noDestination = value;
                                      _pickedDestination = 'Free for all';
                                      // if (_noDestination == true &&
                                      //     _pickedDestination != null &&
                                      //     _pickedDestination != '') {
                                      //   _pickedDestination = 'Free for all';
                                      // }
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Enter Space Information',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  buildFeature(
                                      Icons.hotel,
                                      "Bedroom",
                                      _bedroomController,
                                      _bedroomValidator,
                                      modalState),
                                  //SizedBox(width: 25),
                                  //SizedBox(width: size.width * 0.05),
                                  buildFeature(
                                      Icons.desktop_mac,
                                      "Workspaces",
                                      _workspaceController,
                                      _workspaceValidator,
                                      modalState),
                                  //SizedBox(width: 25),
                                  buildFeature(
                                      Icons.wc,
                                      "Bathroom",
                                      _bathroomController,
                                      _bathroomValidator,
                                      modalState),
                                  //SizedBox(width: 25),
                                  buildFeature(
                                      Icons.kitchen,
                                      "Kitchen",
                                      _kitchenController,
                                      _kitchenValidator,
                                      modalState),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Text('Square Meter: '),
                                    SizedBox(
                                      //width: 100,
                                      width: size.width * 0.1,

                                      child: TextField(
                                        controller: _sqmController,
                                        decoration: InputDecoration(
                                          //labelText: 'Square Meter',
                                          hintText: "  m²",
                                          errorText: _sqmValidator
                                              ? 'Bedroom Count can\'t be empty'
                                              : null,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        onChanged: (value) {
                                          modalState(() {
                                            if (_sqmController.text.isEmpty) {
                                              print('text not valid.');
                                            } else {
                                              _sqm = double.parse(value);
                                            }
                                          });
                                        }, // Only numbers can be entered
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('Wifi Available '),
                                    SizedBox(
                                      width: size.width * 0.05,
                                      //width: 1,
                                      child: Checkbox(
                                        value: _wifi,
                                        onChanged: (bool value) {
                                          modalState(() {
                                            //_wifi = value;
                                            final snackBar = SnackBar(
                                                content: Text(
                                                    'Conspaces requires all Spaces to have Wifi available'));
                                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                            _scaffoldKey.currentState
                                                .showSnackBar(snackBar);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Row(
                            //   children: [
                            //     Text('Wifi: '),
                            //     Checkbox(
                            //       value: _wifi,
                            //       onChanged: (bool value) {
                            //         modalState(() {
                            //           _wifi = value;
                            //         });
                            //       },
                            //     ),
                            //   ],
                            // ),
                            SizedBox(height: 30),
                            Text(
                              'Upload Main Image',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  //width: 150,
                                  width: size.width * 0.3,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
                                  ),
                                  child: _storedImage != null
                                      ? Image.file(
                                          _storedImage,
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
                                    onPressed: () => _takePicture(modalState),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Upload Additional Images (optional)',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  //width: 150,
                                  width: size.width * 0.3,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
                                  ),
                                  child: _firstAdditionalImage != null
                                      ? Image.file(
                                          _firstAdditionalImage,
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
                                  width: size.width * 0.05,
                                ),
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
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  //width: 150,
                                  width: size.width * 0.3,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
                                  ),
                                  child: _secondAdditionalImage != null
                                      ? Image.file(
                                          _secondAdditionalImage,
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
                                  width: size.width * 0.05,
                                ),
                                Expanded(
                                  child: FlatButton.icon(
                                    icon: Icon(Icons.camera),
                                    label: Text('Take Picture'),
                                    textColor: Theme.of(context).primaryColor,
                                    onPressed: () =>
                                        _takeSecondAdditionalPicture(
                                            modalState),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : Container(
                          color: Color(0xFF4845c7),
                          child: SafeArea(
                            child: RaisedButton.icon(
                              icon: Icon(Icons.add),
                              label: Text('Add property'),
                              onPressed: ((!_titleController.text.isEmpty &&
                                          _storedImage != null &&
                                          !_isButtonDisabled &&
                                          _pickedLocation != '' &&
                                          _pickedLocation != null &&
                                          //_pickedDestination != '' &&
                                          // entweder pickeddestination hat eine adresse oder es wurde noDestination ausgewählt (free for all)
                                          //_pickedDestination != null)
                                          _pickedDestination ==
                                              'Free for all' &&
                                          _noDestination == true &&
                                          // _bedroomCount > 0 &&
                                          // _sqm > 0 &&
                                          // _kitchenCount > 0 &&
                                          // _workspaceCount > 0 &&
                                          // _bathroomCount > 0 &&
                                          _wifi == true) ||
                                      (!_titleController.text.isEmpty &&
                                          _storedImage != null &&
                                          !_isButtonDisabled &&
                                          _pickedLocation != '' &&
                                          _pickedLocation != null &&
                                          _pickedDestination != '' &&
                                          _noDestination == false &&
                                          _pickedDestination != null &&
                                          // _bedroomCount > 0 &&
                                          // _sqm > 0 &&
                                          // _kitchenCount > 0 &&
                                          // _workspaceCount > 0 &&
                                          // _bathroomCount > 0 &&
                                          _wifi == true))
                                  ? () => _sendMessage(modalState)
                                  : null,
                              elevation: 0,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              color: Color(0xFF4845c7),
                            ),
                          ),
                        ),
                ],
              );
            }),
          );
        });
  }

  //TOOD: setState in _takePicture is not really working. The rebuild is not triggered / picture is not updated.
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

  Widget buildFeature(IconData iconData, String text,
      TextEditingController givenController, bool givenValidator, modalState) {
    return Column(
      children: [
        Icon(
          iconData,
          //color: Colors.yellow[700],
          color: Colors.black,
          size: 28,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
        Container(
          width: 10,
          height: 40,
          child: TextField(
            controller: givenController,
            decoration: InputDecoration(
              hintText: "0",
              errorText: givenValidator ? 'Count can\'t be empty' : null,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              modalState(() {
                if (givenController.text.isEmpty) {
                  //print('text not valid.');
                } else {
                  if (text == 'Bedroom') {
                    _bedroomCount = double.parse(value);
                  } else if (text == "Workspaces") {
                    _workspaceCount = double.parse(value);
                  } else if (text == "Bathroom") {
                    _bathroomCount = double.parse(value);
                  } else {
                    _kitchenCount = double.parse(value);
                  }
                }
              });
            }, // Only numbers can be entered
          ),
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (_isAnon)
      return Scaffold(
        //key: _scaffoldKey,
        //backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        //body: AuthForm(_submitAuthForm, _isLoading, _scaffoldKey),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Listings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(height: 10),
                Text(
                  'Sign up to add and manage your spaces.',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: size.width * 0.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FlatButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      color: kPrimaryColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthScreen(
                              isAnon: true,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Signup',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListingsUnique(),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewProperty(context, size),
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFF4845c7),
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

    //var address = await Geocoder.local.findAddressesFromQuery(p.description);
    //var coordinates = new Coordinates(lat, lng);

    var address = await Geocoder.google(kGoogleApiKey)
        .findAddressesFromQuery(p.description);

    return [address.first.locality, lat, lng];
    //return address.first.addressLne;
  }
}
