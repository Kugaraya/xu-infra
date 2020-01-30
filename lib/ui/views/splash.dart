import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/ui/views/dashboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 4,
      navigateAfterSeconds: DashboardScreen(
        auth: Auth(),
        db: Firestore.instance,
        fs: FirebaseStorage.instance,
      ),
      image: Image.asset('assets/logo.png'),
      backgroundColor: Colors.white,
      loaderColor: Theme.of(context).primaryColor,
      loadingText: Text("Loading..."),
      styleTextUnderTheLoader:
          TextStyle(fontSize: 8.0, color: Colors.grey[400]),
      photoSize: 100.0,
      onClick: () => Fluttertoast.showToast(
          msg: "Relax, the app will load in a bit",
          backgroundColor: Colors.black38,
          gravity: ToastGravity.BOTTOM,
          fontSize: 12.0,
          textColor: Colors.white,
          timeInSecForIos: 1,
          toastLength: Toast.LENGTH_SHORT),
    );
  }
}
