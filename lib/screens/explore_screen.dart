import 'package:conspacesapp/screens/user_listings_screen.dart';
import 'package:flutter/material.dart';
import '../credentials.dart';
import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'listings_screen.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: KEY);

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _validateLocation = false;
  bool _validateDestination = false;
  String _pickedLocation = '';
  String _pickedDestination = '';

  final _locationController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    _pickedDestination = '';
    _pickedLocation = '';
    super.initState();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: size.width * 0.05, right: size.width * 0.05),
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: SizedBox(
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
                                labelText: 'Select Location',
                                labelStyle: TextStyle(height: 0),
                                errorText: _validateLocation
                                    ? 'Tap on the field to search and select a location.'
                                    : null),
                            controller: _locationController,
                            onTap: () async {
                              // show input autocomplete with selected mode
                              // then get the Prediction selected
                              Prediction p = await PlacesAutocomplete.show(
                                  context: context, apiKey: KEY);
                              final locationData =
                                  displayPrediction(p).then((location) {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  _pickedLocation = location[0];
                                  _locationController.text = location[1];
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
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
                          TextField(
                            decoration: InputDecoration(
                                labelText: 'Select Destination',
                                labelStyle: TextStyle(height: 0),
                                errorText: _validateDestination
                                    ? 'Tap on the field to search and select a location.'
                                    : null),
                            controller: _destinationController,
                            onTap: () async {
                              // show input autocomplete with selected mode
                              // then get the Prediction selected
                              Prediction p = await PlacesAutocomplete.show(
                                  context: context, apiKey: KEY);
                              final locationData =
                                  displayPrediction(p).then((location) {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  _pickedDestination = location[0];
                                  _destinationController.text = location[1];
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.02),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: size.width,
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                if (_pickedLocation != '' &&
                                    _pickedDestination != '') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListingsScreen(
                                          _pickedLocation, _pickedDestination),
                                    ),
                                  );
                                } else {
                                  if (_pickedLocation == '' &&
                                      _pickedDestination != '') {
                                    setState(() {
                                      _validateLocation = true;
                                      _validateDestination = false;
                                    });
                                  } else if (_pickedLocation != '' &&
                                      _pickedDestination == '') {
                                    setState(() {
                                      _validateDestination = true;
                                      _validateLocation = false;
                                    });
                                  } else {
                                    setState(() {
                                      _validateLocation = true;
                                      _validateDestination = true;
                                    });
                                  }
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
    var placeId;

    var address =
        await Geocoder.google(KEY).findAddressesFromQuery(p.description);
    if (address.first.locality != null) {
      // get place id of the city
      PlacesSearchResponse response =
          await _places.searchByText(address.first.locality);

      placeId = response.results.first.placeId;
    } else {
      placeId = p.placeId;
    }

    return [placeId, address.first.addressLine];
  }
}
