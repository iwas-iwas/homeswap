import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/tabs_screen.dart';
import './screens/auth_screen.dart';
import './screens/slpash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import './widgets/database_service.dart';
import './widgets/storage_service.dart';
import './screens/Signup/signup_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

void main() => runApp(
      MyApp(),
    );

// void main() {
//   runApp(DevicePreview(
//     builder: (context) => MyApp(),
//     enabled: !kReleaseMode, // remove devicepreview if app is in release mode
//   ));
// }

class MyApp extends StatelessWidget {
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
