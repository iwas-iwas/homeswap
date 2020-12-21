import 'package:conspacesapp/screens/user_listings_screen.dart';

import 'package:flutter/material.dart';
import '../credentials.dart';
import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import './listings_screen.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: PLACES_API_KEY);

class ExploreScreenTest extends StatefulWidget {
  @override
  _ExploreScreenTestState createState() => _ExploreScreenTestState();
}

class _ExploreScreenTestState extends State<ExploreScreenTest> {
  String _pickedLocation = '';
  String _pickedDestination = '';
  String _pickedLocationAddress = '';
  String _pickedDestinationAddress = '';

  final _locationController = TextEditingController();
  var _enteredLocation;

  final _destinationController = TextEditingController();
  var _enteredDestination;

  @override
  void initState() {
    _pickedDestination = '';
    _pickedLocation = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      //resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: size.width * 0.05,
              //top: size.height * 0.075,
              right: size.width * 0.05),
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * 0.06,
                            child: Text(
                              'Explore',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: size.width * 0.09,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.05,
                            child: Text(
                              "Work from Anywhere",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * 0.06,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //SizedBox(height: size.height * 0.015),
                    // SizedBox(
                    //   height: size.height * 0.05,
                    //   child: Text(
                    //     "Work from Anywhere",
                    //     style: TextStyle(
                    //       color: Colors.black,
                    //       fontSize: size.width * 0.06,
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: size.height * 0.09),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * 0.045,
                            child: Text(
                              'My space is in',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextField(
                            decoration: InputDecoration(
                                labelText: 'Enter Location',
                                labelStyle: TextStyle(height: 0)),
                            controller: _locationController,
                            onTap: () async {
                              // show input autocomplete with selected mode
                              // then get the Prediction selected
                              Prediction p = await PlacesAutocomplete.show(
                                  context: context, apiKey: PLACES_API_KEY);
                              final locationData =
                                  displayPrediction(p).then((location) {
                                setState(() {
                                  _pickedLocation = location[0];
                                  _pickedLocationAddress = location[1];
                                  _locationController.text = location[1];
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    //SizedBox(height: 20),
                    //SizedBox(height: size.height * 0.03),
                    // SizedBox(
                    //   height: size.height * 0.09,
                    //   child: TextField(
                    //     decoration: InputDecoration(
                    //         labelText: 'Enter Location',
                    //         labelStyle: TextStyle(height: 0)),
                    //     controller: _locationController,
                    //     onTap: () async {
                    //       // show input autocomplete with selected mode
                    //       // then get the Prediction selected
                    //       Prediction p = await PlacesAutocomplete.show(
                    //           context: context, apiKey: PLACES_API_KEY);
                    //       final locationData = displayPrediction(p).then((location) {
                    //         setState(() {
                    //           _pickedLocation = location[0];
                    //           _pickedLocationAddress = location[1];
                    //           _locationController.text = location[1];
                    //         });
                    //       });
                    //     },
                    //   ),
                    // ),
                    //SizedBox(height: 60),
                    //SizedBox(height: size.height * 0.09),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * 0.045,
                            child: Text(
                              'I want to work in',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                          //height: size.height * 0.09,
                          //height: 100,
                          TextField(
                            decoration: InputDecoration(
                                labelText: 'Enter Destination',
                                labelStyle: TextStyle(height: 0)),
                            controller: _destinationController,
                            onTap: () async {
                              // show input autocomplete with selected mode
                              // then get the Prediction selected
                              Prediction p = await PlacesAutocomplete.show(
                                  context: context, apiKey: PLACES_API_KEY);
                              final locationData =
                                  displayPrediction(p).then((location) {
                                setState(() {
                                  //FocusScope.of(context).unfocus();
                                  _pickedDestination = location[0];
                                  _pickedDestinationAddress = location[1];
                                  _destinationController.text = location[1];
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 20),
                    // SizedBox(height: size.height * 0.03),

                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.02),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: size.width,
                            //height: 55,
                            //height: size.height * 0.08,
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                if (_pickedLocation != '' &&
                                    _pickedLocation != null &&
                                    _pickedDestination != '' &&
                                    _pickedDestination != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListingsScreen(
                                          _pickedLocation, _pickedDestination),
                                    ),
                                  );
                                }
                              },
                              backgroundColor: const Color(0xFF4845c7),
                              //icon: Icon(Icons.add),
                              label: Text(
                                'Explore Swaps',
                                style: TextStyle(fontSize: 18),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<String>> displayPrediction(Prediction p) async {
  if (p != null) {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    // print(detail);
    // print(p.placeId);
    // print(detail.result.geometry.location);

    var placeId = p.placeId;
    double lat = detail.result.geometry.location.lat;
    double lng = detail.result.geometry.location.lng;

    String street = detail.result.geometry.location.toString();
    String loc = detail.result.formattedAddress.toString();
    //var coordinates = new Coordinates(lat, lng);
    //var address = await Geocoder.local.findAddressesFromQuery(p.description);
    var address = await Geocoder.google(kGoogleApiKey)
        .findAddressesFromQuery(p.description);

    // print('address');
    // print(address);

    // //print(lat);
    // //print(lng);
    // // print(street);
    // // print(loc);
    // print(address.first.addressLine);
    // print(address.first.countryName);
    // print(address.first.postalCode);
    // print(address.first.adminArea);
    // print(address.first.featureName);
    // print(address.first.locality);

    return [address.first.locality, address.first.addressLine];
    //return address.first.addressLne;
  }
}
