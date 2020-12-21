// This is the final screen to handle in-app purchase transactions.

import 'package:conspacesapp/screens/tabs_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants.dart';
import 'components.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

PurchaserInfo _purchaserInfo;

class UpgradeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  Offerings _offerings;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
    } on PlatformException catch (e) {
      print(e);
    }

    Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _purchaserInfo = purchaserInfo;
      _offerings = offerings;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_purchaserInfo == null) {
      return TopBarAgnosticNoIcon(
        text: "Upgrade Screen",
        style: kSendButtonTextStyle,
        uniqueHeroTag: 'upgrade_screen',
        child: Scaffold(
            backgroundColor: kColorPrimary,
            body: Center(
                child: Text(
              "Loading...",
            ))),
      );
    } else {
      if (_purchaserInfo.entitlements.all.isNotEmpty &&
          _purchaserInfo.entitlements.all['all_features'].isActive != null) {
        appData.isPro =
            _purchaserInfo.entitlements.all['all_features'].isActive;
      } else {
        appData.isPro = false;
      }
      if (appData.isPro) {
        return ProScreen();
      } else {
        return UpsellScreen(
          offerings: _offerings,
        );
      }
    }
  }
}

class UpsellScreen extends StatefulWidget {
  final Offerings offerings;

  UpsellScreen({Key key, @required this.offerings}) : super(key: key);

  @override
  _UpsellScreenState createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
  _launchURLWebsite(String zz) async {
    if (await canLaunch(zz)) {
      await launch(zz);
    } else {
      throw 'Could not launch $zz';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offerings != null) {
      //print('offerings is not null');
      //print(widget.offerings.current.toString());
      //print('--');
      //print(widget.offerings.toString());
      final offering = widget.offerings.current;
      if (offering != null) {
        final monthly = offering.monthly;
        if (monthly != null) {
          return TopBarAgnosticNoIcon(
            text: "Upgrade Screen",
            style: TextStyle(color: Colors.white),
            uniqueHeroTag: 'purchase_screen',
            child: Scaffold(
                backgroundColor: kColorPrimary,
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // SvgPicture.asset(
                        //   "assets/icons/black-logo.svg",
                        //   height: 150,
                        // ),
                        //SizedBox(height: 10),
                        // Text(
                        //   'Choose the monthly plan plan to get access to all features of the app.',
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(color: Colors.black),
                        // ),
                        //SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Get a subscription to Conspaces, enabiling these premium features:\n'),
                              Text('- Send and receive swap requests'),
                              Text('- Accept swap requests'),
                              Text('- Send email to other users'),
                            ],
                          ),
                        ),

                        PurchaseButton(package: monthly),
                        GestureDetector(
                          child: Container(
                            decoration: new BoxDecoration(
                              //color: kColorPrimaryDark,
                              color: kPrimaryColor,
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(
                                'Restore Purchase',
                                style: kSendButtonTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            try {
                              PurchaserInfo restoredInfo =
                                  await Purchases.restoreTransactions();
                              appData.isPro = restoredInfo
                                  .entitlements.all["all_features"].isActive;
                              if (appData.isPro) {
                                Alert(
                                  context: context,
                                  style: kWelcomeAlertStyle,
                                  image: SvgPicture.asset(
                                    "assets/icons/black-logo.svg",
                                    height: 150,
                                  ),
                                  title: "Congratulations",
                                  content: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0,
                                            right: 8.0,
                                            left: 8.0,
                                            bottom: 20.0),
                                        child: Text(
                                          'Your purchase has been restored!',
                                          textAlign: TextAlign.center,
                                          style: kSendButtonTextStyle,
                                        ),
                                      )
                                    ],
                                  ),
                                  buttons: [
                                    DialogButton(
                                      radius: BorderRadius.circular(10),
                                      child: Text(
                                        "Continue",
                                        style: kSendButtonTextStyle,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      },
                                      width: 127,
                                      color: kColorAccent,
                                      height: 52,
                                    ),
                                  ],
                                ).show();
                              } else {
                                Alert(
                                  context: context,
                                  style: kWelcomeAlertStyle,
                                  image: SvgPicture.asset(
                                    "assets/icons/black-logo.svg",
                                    height: 150,
                                  ),
                                  title: "Error",
                                  content: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0,
                                            right: 8.0,
                                            left: 8.0,
                                            bottom: 20.0),
                                        child: Text(
                                          'There was an error. Please try again later',
                                          textAlign: TextAlign.center,
                                          style: kSendButtonTextStyle,
                                        ),
                                      )
                                    ],
                                  ),
                                  buttons: [
                                    DialogButton(
                                      radius: BorderRadius.circular(10),
                                      child: Text(
                                        "Continue",
                                        style: kSendButtonTextStyle,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      },
                                      width: 127,
                                      color: kColorAccent,
                                      height: 52,
                                    ),
                                  ],
                                ).show();
                              }
                            } on PlatformException catch (e) {
                              //print('----xx-----');
                              var errorCode =
                                  PurchasesErrorHelper.getErrorCode(e);
                              if (errorCode ==
                                  PurchasesErrorCode.purchaseCancelledError) {
                                //print("User cancelled");
                              } else if (errorCode ==
                                  PurchasesErrorCode.purchaseNotAllowedError) {
                                //print("User not allowed to purchase");
                              }
                              Alert(
                                context: context,
                                style: kWelcomeAlertStyle,
                                image: SvgPicture.asset(
                                  "assets/icons/black-logo.svg",
                                  height: 150,
                                ),
                                title: "Error",
                                content: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20.0,
                                          right: 8.0,
                                          left: 8.0,
                                          bottom: 20.0),
                                      child: Text(
                                        'There was an error. Please try again later',
                                        textAlign: TextAlign.center,
                                        style: kSendButtonTextStyle,
                                      ),
                                    )
                                  ],
                                ),
                                buttons: [
                                  DialogButton(
                                    radius: BorderRadius.circular(10),
                                    child: Text(
                                      "Continue",
                                      style: kSendButtonTextStyle,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                    width: 127,
                                    color: kColorAccent,
                                    height: 52,
                                  ),
                                ],
                              ).show();
                            }
                            return UpgradeScreen();
                          },
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: Center(
                              child: Text.rich(
                            TextSpan(
                                text:
                                    "If you purchase the monthly subscription a ${monthly.product.priceString} purchase will be applied to your iTunes account. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription. For more information, see our ",
                                // style: TextStyle(
                                //   fontSize: 16,
                                //   color: kPrimaryColor,
                                // ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        //fontSize: 16,
                                        color: kPrimaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launch(
                                              'https://www.iubenda.com/terms-and-conditions/18657475');
                                          // code to open / launch privacy policy link here
                                        }),
                                  TextSpan(
                                      text: ' & ',
                                      style: TextStyle(
                                        //fontSize: 16,
                                        color: kPrimaryColor,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                                // fontSize: 10,
                                                // color: kPrimaryColor,
                                                decoration:
                                                    TextDecoration.underline),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                launch(
                                                    'https://www.iubenda.com/privacy-policy/18657475');
                                                // code to open / launch privacy policy link here
                                              })
                                      ])
                                ]),
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ],
                    )),
                  ),
                )),
          );
        }
      }
    }
    return TopBarAgnosticNoIcon(
      text: "Upgrade Screen",
      style: kSendButtonTextStyle,
      uniqueHeroTag: 'upgrade_screen1',
      child: Scaffold(
          backgroundColor: kColorPrimary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(
                    Icons.error,
                    color: kColorText,
                    size: 44.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "There was an error. Please check that your device is allowed to make purchases and try again. Please contact us at conspaces@outlook.com if the problem persists.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class PurchaseButton extends StatefulWidget {
  final Package package;

  PurchaseButton({Key key, @required this.package}) : super(key: key);

  @override
  _PurchaseButtonState createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<PurchaseButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: RaisedButton(
              onPressed: () async {
                try {
                  _purchaserInfo =
                      await Purchases.purchasePackage(widget.package);
                  appData.isPro =
                      _purchaserInfo.entitlements.all["all_features"].isActive;
                  if (appData.isPro) {
                    Alert(
                      context: context,
                      style: kWelcomeAlertStyle,
                      image: SvgPicture.asset(
                        "assets/icons/black-logo.svg",
                        height: 150,
                      ),
                      title: "Congratulations",
                      content: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                            child: Text(
                              'You now have full access to the app',
                              textAlign: TextAlign.center,
                              style: kSendButtonTextStyle,
                            ),
                          )
                        ],
                      ),
                      buttons: [
                        DialogButton(
                          radius: BorderRadius.circular(10),
                          child: Text(
                            "Continue",
                            style: kSendButtonTextStyle,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TabsScreen(),
                              ),
                            );
                            // Navigator.of(context, rootNavigator: true).pop();
                            // Navigator.of(context, rootNavigator: true).pop();
                            // Navigator.of(context, rootNavigator: true).pop();
                          },
                          width: 127,
                          color: kColorAccent,
                          height: 52,
                        ),
                      ],
                    ).show();
                  } else {
                    Alert(
                      context: context,
                      style: kWelcomeAlertStyle,
                      image: SvgPicture.asset(
                        "assets/icons/black-logo.svg",
                        height: 150,
                      ),
                      title: "Error",
                      content: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                            child: Text(
                              'There was an error. Please try again later',
                              textAlign: TextAlign.center,
                              style: kSendButtonTextStyle,
                            ),
                          )
                        ],
                      ),
                      buttons: [
                        DialogButton(
                          radius: BorderRadius.circular(10),
                          child: Text(
                            "Continue",
                            style: kSendButtonTextStyle,
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          width: 127,
                          color: kColorAccent,
                          height: 52,
                        ),
                      ],
                    ).show();
                  }
                } on PlatformException catch (e) {
                  //print('----xx-----');
                  var errorCode = PurchasesErrorHelper.getErrorCode(e);
                  if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
                    //print("User cancelled");
                  } else if (errorCode ==
                      PurchasesErrorCode.purchaseNotAllowedError) {
                    //print("User not allowed to purchase");
                  }
                  Alert(
                    context: context,
                    style: kWelcomeAlertStyle,
                    image: SvgPicture.asset(
                      "assets/icons/black-logo.svg",
                      height: 150,
                    ),
                    title: "Error",
                    content: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, right: 8.0, left: 8.0, bottom: 20.0),
                          child: Text(
                            'There was an error. Please try again later',
                            textAlign: TextAlign.center,
                            style: kSendButtonTextStyle,
                          ),
                        )
                      ],
                    ),
                    buttons: [
                      DialogButton(
                        radius: BorderRadius.circular(10),
                        child: Text(
                          "Continue",
                          style: kSendButtonTextStyle,
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        width: 127,
                        color: kColorAccent,
                        height: 52,
                      ),
                    ],
                  ).show();
                }
                return UpgradeScreen();
              },
              textColor: kColorText,
              color: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  'Buy ${widget.package.product.title}\n${widget.package.product.priceString}',
                  style: kSendButtonTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        // Padding(
        //   padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
        //   child: Text(
        //     '${widget.package.product.description}',
        //     textAlign: TextAlign.center,
        //     style: TextStyle(color: Colors.black),
        //   ),
        // )
      ],
    );
  }
}

class ProScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopBarAgnosticNoIcon(
      text: "Premium Screen",
      style: TextStyle(color: Colors.white),
      uniqueHeroTag: 'pro_screen',
      child: Scaffold(
          backgroundColor: kColorPrimary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(
                    Icons.star,
                    color: kPrimaryColor,
                    size: 44.0,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      "You are a Pro user.\n\nYou can use the app in all its functionality.\nPlease contact us at conspaces@outlook.com if you have any problem.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    )),
                Text(
                    'Member since ${convertDateTimeDisplay(DateTime.parse(_purchaserInfo.entitlements.all['all_features'].originalPurchaseDate).toString())}'),
                SizedBox(height: 10),
                Text(
                    'Expires at ${convertDateTimeDisplay(DateTime.parse(_purchaserInfo.entitlements.all['all_features'].expirationDate).toString())}'),
              ],
            ),
          )),
    );
  }

  convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }
}
