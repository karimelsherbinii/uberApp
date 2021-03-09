import './dataprovider/appdata.dart';
import './globalvariable.dart';
import './screens/loginpage.dart';
import './screens/mainpage.dart';
import './screens/registrationpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:74522177576:ios:a838855ee93d2d5b5c851d',
            gcmSenderID: '74522177576',
            databaseURL: 'https://geetaxi-47a21-default-rtdb.firebaseio.com',
          )
        : const FirebaseOptions(
            googleAppID: '1:74522177576:android:8d4e0bbae5575de75c851d',
            apiKey: 'AIzaSyBYLAu4hXN__HQ1Sl2sAZKqHS2v8N9TYGM',
            databaseURL: 'https://geetaxi-47a21-default-rtdb.firebaseio.com',
          ),
  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
        ),
        initialRoute: MainPage.id,
        //(currentFirebaseUser == null) ? LoginPage.id :
        routes: {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          MainPage.id: (context) => MainPage(),
        },
      ),
    );
  }
}
