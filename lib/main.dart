import 'package:conspacesapp/payment/components.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/tabs_screen.dart';
import './screens/auth_screen.dart';
import './screens/slpash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';
import './credentials.dart';

void main() => runApp(
      MyApp(),
    );

// void main() {
//   runApp(DevicePreview(
//     builder: (context) => MyApp(),
//     enabled: !kReleaseMode, // remove devicepreview if app is in release mode
//   ));
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    appData.isPro = false;

    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(RABBIT_API_KEY);

    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print(purchaserInfo.toString());
      if (purchaserInfo.entitlements.all['all_features'] != null) {
        appData.isPro = purchaserInfo.entitlements.all['all_features'].isActive;
      } else {
        appData.isPro = false;
      }
    } on PlatformException catch (e) {
      print(e);
    }

    print('#### is user pro? ${appData.isPro}');
  }

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, appSnapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Conspaces',
            theme: ThemeData(
              primarySwatch: MaterialColor(0xFF4845c7, {
                50: Color(0xFF4845c7),
                100: Color(0xFF4845c7),
                200: Color(0xFF4845c7),
                300: Color(0xFF4845c7),
                400: Color(0xFF4845c7),
                500: Color(0xFF4845c7),
                600: Color(0xFF4845c7),
                700: Color(0xFF4845c7),
                800: Color(0xFF4845c7),
                900: Color(0xFF4845c7),
              }),
              backgroundColor: Colors.grey,
              accentColor: Colors.black,
              accentColorBrightness: Brightness.dark,
              buttonTheme: ButtonTheme.of(context).copyWith(
                buttonColor: Colors.black,
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            home: appSnapshot.connectionState != ConnectionState.done
                ? SplashScreen()
                : StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (ctx, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SplashScreen();
                      }
                      if (userSnapshot.hasData) {
                        return TabsScreen();
                      }
                      return AuthScreen();
                    }),
          );
        });
  }
}
