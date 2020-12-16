import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numberpicker/numberpicker.dart';
import './property_style.dart';
import '../screens/tabs_screen.dart';

class Listings extends StatefulWidget {
  // TODO: Filter Listings by pickedLocation & pickedDestination
  String pickedLocation;
  String pickedDestination;

  int _currentWcValue = 2;
  int _currentWorkspaceValue = 2;
  int _currentBedroomValue = 2;

  int wcCount = -1;
  int workspaceCount = -1;
  int bedroomCount = -1;

  Listings(this.pickedLocation, this.pickedDestination);

  @override
  _ListingsState createState() => _ListingsState();
}

class _ListingsState extends State<Listings> {
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
              HeadingFromExplore(widget.pickedDestination),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('properties')
                      .where('location', isEqualTo: widget.pickedDestination)
                      .where('destination',
                          whereIn: [widget.pickedLocation, 'ffa'])
                      //TODO: ORDER BY HAT DEN BUILDER GEBROCHEN, DA VERMUTLICH DER USERID INDEX DER EINGERICHTET IST DADURCH AKTIV WURDE! GGF. WEITEREN INDEX ERSTELLEn FÜR LOCATION/DESTINATION
                      //.orderBy('createdAt', descending: true)
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
                    else if (filterApplied && filteredPropertyList.length > 0) {
                      finalProperties = filteredPropertyList;
                    }

                    return ListView.builder(
                      //scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      // order messages from bottom to top
                      //reverse: true,
                      //itemCount: documents.length,
                      itemCount: finalProperties.length,
                      itemBuilder: (ctx, index) => PropertyStyle(
                        finalProperties[index].data()['title'],
                        //documents[index]['userId'],
                        // each property contains the username, specified in new_property upon pressing send
                        finalProperties[index].data()['username'],
                        finalProperties[index].data()['userImage'],
                        finalProperties[index].data()['location'],
                        finalProperties[index].data()['destination'],
                        // TODO: evaluate if "is me" is needed. maybe to give specific rights or highlight smth?
                        finalProperties[index].data()['userId'] == user.uid,
                        finalProperties[index].data()['userId'],
                        user.uid,
                        finalProperties[index].id,
                        false,
                        finalProperties[index].data()['latitude'],
                        finalProperties[index].data()['longitude'],
                        finalProperties[index].data()['bathrooms'],
                        finalProperties[index].data()['bedrooms'],
                        finalProperties[index].data()['kitchen'],
                        finalProperties[index].data()['workspaces'],
                        finalProperties[index].data()['sqm'],
                        finalProperties[index].data()['firstAdditionalImage'],
                        finalProperties[index].data()['secondAdditionalImage'],
                        finalProperties[index].data()['userProfileImage'],
                        finalProperties[index].data()['userMail'],
                        // make sure that flutter makes sure to efficiently update the list with new items
                        key: ValueKey(documents[index].id),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }
}

class HeadingFromExplore extends StatelessWidget {
  HeadingFromExplore(this.pickedDestination);

  final String pickedDestination;

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
          child: Text(
            pickedDestination,
            style: TextStyle(
                fontSize: 36, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
