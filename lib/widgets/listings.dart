import 'package:auto_size_text/auto_size_text.dart';
import 'package:conspacesapp/screens/user_listings_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:numberpicker/numberpicker.dart';
import '../constants.dart';
import './property_style.dart';
import '../screens/tabs_screen.dart';
import 'package:google_maps_webservice/places.dart';

class Listings extends StatefulWidget {
  String pickedLocation;
  String pickedDestination;

  int _currentWcValue = 2;
  int _currentWorkspaceValue = 2;
  int _currentBedroomValue = 2;

  int wcCount = -1;
  int workspaceCount = -1;
  int bedroomCount = -1;

  Listings(this.pickedLocation, this.pickedDestination);

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: KEY);

  @override
  _ListingsState createState() => _ListingsState();
}

class _ListingsState extends State<Listings> {
  String _city = '';

  void initState() {
    super.initState();
    _getCity(widget.pickedDestination);
  }

  Future<void> _getCity(placeId) async {
    PlacesDetailsResponse detail =
        await widget._places.getDetailsByPlaceId(widget.pickedDestination);

    var addressInitial = detail.result.formattedAddress;
    setState(() {
      _city = addressInitial;
    });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalState) {
            return Wrap(
              children: [
                Container(
                  //padding: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  width: double.infinity,
                  child: RaisedButton.icon(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      setState(() {
                        widget.wcCount = -1;
                        widget.workspaceCount = -1;
                        widget.bedroomCount = -1;
                      });
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.restore_outlined, color: Colors.black),
                    label: Text(
                      'Clear Filter',
                      style: TextStyle(color: Colors.black),
                    ),
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 24, left: 24, top: 32),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.hotel),
                              SizedBox(width: 10),
                              Text("Select the amount of Bedrooms"),
                            ],
                          ),
                          NumberPicker.horizontal(
                              initialValue: widget._currentBedroomValue,
                              minValue: 1,
                              maxValue: 5,
                              onChanged: (newValue) => modalState(() =>
                                  widget._currentBedroomValue = newValue)),
                          //Text("Current number: ${widget._currentValue}"),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 24, left: 24),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.desktop_mac),
                              SizedBox(width: 10),
                              Text("Select the amount of Workspaces"),
                            ],
                          ),
                          NumberPicker.horizontal(
                              initialValue: widget._currentWorkspaceValue,
                              minValue: 1,
                              maxValue: 5,
                              onChanged: (newValue) => modalState(() {
                                    widget._currentWorkspaceValue = newValue;
                                  })),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 24, left: 24, bottom: 24),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.wc),
                              SizedBox(width: 10),
                              Text("Select the amount of Bathrooms"),
                            ],
                          ),
                          NumberPicker.horizontal(
                              initialValue: widget._currentWcValue,
                              minValue: 1,
                              maxValue: 5,
                              onChanged: (newValue) => modalState(
                                  () => widget._currentWcValue = newValue)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Color(0xFF4845c7),
                  width: double.infinity,
                  child: SafeArea(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Apply Filter'),
                      onPressed: () {
                        setState(() {
                          widget.wcCount = widget._currentWcValue;
                          widget.workspaceCount = widget._currentWorkspaceValue;
                          widget.bedroomCount = widget._currentBedroomValue;
                        });
                        Navigator.pop(context);
                      },
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

  Widget buildOption(String text, bool selected) {
    return Container(
      height: 45,
      width: 65,
      decoration: BoxDecoration(
          color: selected ? Colors.blue[900] : Colors.transparent,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
          border: Border.all(
            width: selected ? 0 : 1,
            color: Colors.grey,
          )),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: current user is not needed for dislpaying the listings, it is needed when creating and storing new property objects. s
    // so remove current user here??
    final user = FirebaseAuth.instance.currentUser;
    // once we got the currently logged in user, return streambuilder and build the list view new for every new property
    //return StreamBuilder(
    if (_city != '')
      return Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 10),
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
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showBottomSheet();
                  },
                  child: Icon(
                    Icons.filter_list,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingFromExplore(_city),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('properties')
                        .where('locationPlaceId',
                            isEqualTo: widget.pickedDestination)
                        .where('destinationPlaceId',
                            whereIn: [widget.pickedLocation, 'ffa'])
                        //.orderBy('createdAt', descending: true)
                        .snapshots(),
                    // whenever the properties collection receives a new value, the function inside of the builder argument is executed
                    builder: (ctx, streamSnapshot) {
                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
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
                      List<dynamic> finalProperties = [];
                      List<dynamic> filteredPropertyList = [];
                      bool filterApplied = false;

                      // if filter is applied, filter the full property list depending on the values chosen in the filter. dont build the document list before filter has been applied. the if makes sure of that.
                      if (widget.wcCount != -1 &&
                          widget.bedroomCount != -1 &&
                          widget._currentWorkspaceValue != -1) {
                        filterApplied = true;
                        for (var i = 0; i <= documents.length - 1; i++) {
                          dynamic property = documents[i].data();
                          if (property['workspaces'] == widget.workspaceCount &&
                              property['bathrooms'] == widget.wcCount &&
                              property['bedrooms'] == widget.bedroomCount) {
                            filteredPropertyList.add(documents[i]);
                          }
                        }
                      }

                      // if no filter is applied, just take all of the documents from the stream. if filter is applied and filtered properties exist, render only them, else if filter applied and no filtered properties are in the db, return that nothing has been found.
                      if (!filterApplied) {
                        finalProperties = documents;
                      } else if (filterApplied &&
                          filteredPropertyList.length == 0)
                        return Center(
                          child: Column(
                            children: [
                              Text('No spaces found for the specified filter.'),
                              SizedBox(height: 10),
                              RaisedButton.icon(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onPressed: () {
                                  setState(() {
                                    widget.wcCount = -1;
                                    widget.workspaceCount = -1;
                                    widget.bedroomCount = -1;
                                  });
                                },
                                icon: Icon(Icons.restore_outlined,
                                    color: Colors.black),
                                label: Text(
                                  'Clear Filter',
                                  style: TextStyle(color: Colors.black),
                                ),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        );
                      else if (filterApplied &&
                          filteredPropertyList.length > 0) {
                        finalProperties = filteredPropertyList;
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: finalProperties.length,
                        itemBuilder: (ctx, index) => PropertyStyle(
                          finalProperties[index].data()['title'],
                          finalProperties[index].data()['username'],
                          finalProperties[index].data()['userImage'],
                          finalProperties[index].data()['location'],
                          finalProperties[index].data()['destination'],
                          finalProperties[index].data()['userId'] == user.uid,
                          finalProperties[index].data()['userId'],
                          user.uid,
                          finalProperties[index].id,
                          false,
                          finalProperties[index].data()['bathrooms'],
                          finalProperties[index].data()['bedrooms'],
                          finalProperties[index].data()['kitchen'],
                          finalProperties[index].data()['workspaces'],
                          finalProperties[index].data()['sqm'],
                          finalProperties[index].data()['firstAdditionalImage'],
                          finalProperties[index]
                              .data()['secondAdditionalImage'],
                          finalProperties[index].data()['userProfileImage'],
                          finalProperties[index].data()['userMail'],
                          finalProperties[index].data()['locationFullPlaceId'],
                          key: ValueKey(documents[index].id),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ],
      );
    return Center(
      child: SpinKitRotatingCircle(
        color: kPrimaryColor,
        size: 50.0,
      ),
    );
  }
}

class HeadingFromExplore extends StatelessWidget {
  HeadingFromExplore(this.cityName);

  final String cityName;

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
          child: AutoSizeText(
            cityName,
            style: TextStyle(
                fontSize: 36, color: Colors.black, fontWeight: FontWeight.w500),
            maxLines: 1,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
