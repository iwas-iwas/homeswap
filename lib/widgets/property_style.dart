import 'package:conspacesapp/credentials.dart';
import 'package:flutter/material.dart';
import './property_detail.dart';
import 'package:auto_size_text/auto_size_text.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';

class PropertyStyle extends StatelessWidget {
  PropertyStyle(
      this.propertyTitle,
      this.userName,
      this.userImage,
      this.propertyLocation,
      this.propertyDestination,
      this.isMe,
      this.propertyUserId,
      this.currentUserId,
      this.propertyId,
      this.fromListingsUnique,
      // this.latitude,
      // this.longitude,
      this.bathrooms,
      this.bedrooms,
      this.kitchen,
      this.workspaces,
      this.sqm,
      this.firstAdditionalImage,
      this.secondAdditionalImage,
      this.userProfileImage,
      this.userMail,
      this.fullLocationAddress,
      {this.key});

  final Key key;

  final String propertyTitle;
  final String userName;
  final String userImage;
  final String propertyLocation;
  final String propertyDestination;
  final bool isMe;
  final String propertyUserId;
  final String currentUserId;
  final String propertyId;
  final bool fromListingsUnique;
  // final double latitude;
  // final double longitude;
  final double bathrooms;
  final double bedrooms;
  final double kitchen;
  final double workspaces;
  final double sqm;
  final String firstAdditionalImage;
  final String secondAdditionalImage;
  final String userProfileImage;
  final String userMail;
  final String fullLocationAddress;

  //final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: PLACES_API_KEY);

  // Future<String> getCity(placeId) async {
  //   PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);

  //   if (detail.result.adrAddress != null) {
  //     //print('address: ${detail.result.adrAddress}');
  //   }

  //   return detail.result.adrAddress;
  // }

  // Future<List<String>> getLocations(placeId) async {
  //   PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);

  //   var addressInitial = detail.result.formattedAddress;

  //   if (addressInitial != null) {
  //     var address = await Geocoder.google(PLACES_API_KEY)
  //         .findAddressesFromQuery(addressInitial);
  //     // get full location address aswell, but only display it when comming from listings unique or active swaps

  //     return [address.first.locality, address.first.addressLine];
  //   }

  //   return ['', ''];
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Hero(
      tag: Text('hero_property'),
      child: GestureDetector(
        // onTap push to property detail page
        onTap: () {
          //List<dynamic> locations = await getLocations(fullLocationAddress);

          // var locationFromId = await getCity(propertyLocation);
          // var fullLocationFromId = await getFullLocation(fullLocationAddress);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Detail(
                  propertyTitle,
                  userName,
                  userImage,
                  propertyLocation,
                  //locationFromId,
                  // locations[0],
                  propertyUserId,
                  currentUserId,
                  propertyId,
                  fromListingsUnique, // fuer from swaps OR listings unique
                  // latitude,
                  // longitude,
                  bathrooms,
                  bedrooms,
                  kitchen,
                  workspaces,
                  sqm,
                  firstAdditionalImage,
                  secondAdditionalImage,
                  isMe,
                  userProfileImage,
                  userMail,
                  '',
                  fullLocationAddress,
                  fromListingsUnique // only for listings unique
                  //fullLocationFromId
                  //locations[1],
                  //false
                  ),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.only(bottom: 24),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(userImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                      0.5,
                      1.0
                    ],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7)
                    ]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.yellow[700],
                  //     borderRadius: BorderRadius.all(
                  //       Radius.circular(5),
                  //     ),
                  //   ),
                  //   width: 80,
                  //   padding: EdgeInsets.symmetric(vertical: 4),
                  //   child: Center(
                  //     child: Text(
                  //       userName,
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // schiebt das folgende col nach unten innerhalb des image
                  Expanded(
                    child: Container(),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: size.width * 0.64,
                            child: AutoSizeText(
                              propertyTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Icon(
                              //   Icons.location_on,
                              //   color: Colors.white,
                              //   size: 14,
                              // ),
                              // SizedBox(
                              //   width: 4,
                              // ),
                              // Text(
                              //   propertyLocation,
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 14,
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 8,
                              // ),
                              Icon(
                                Icons.zoom_out_map,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                '${sqm.toString()} m²',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.star,
                          //       color: Colors.yellow[700],
                          //       size: 14,
                          //     ),
                          //     SizedBox(
                          //       width: 4,
                          //     ),
                          //     Text(
                          //       "5.0",
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 14,
                          //       ),
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
