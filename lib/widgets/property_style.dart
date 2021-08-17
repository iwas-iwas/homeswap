import 'package:conspacesapp/credentials.dart';
import 'package:flutter/material.dart';
import './property_detail.dart';
import 'package:auto_size_text/auto_size_text.dart';

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Hero(
      tag: Text('hero_property'),
      child: GestureDetector(
        // onTap push to property detail page
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Detail(
                  propertyTitle,
                  userName,
                  userImage,
                  propertyLocation,
                  propertyUserId,
                  currentUserId,
                  propertyId,
                  fromListingsUnique, // fuer from swaps OR listings unique
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
