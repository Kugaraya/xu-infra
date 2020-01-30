import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/ui/views/auth-page.dart';
import 'package:infrastrucktor/ui/views/main-page.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class DashboardScreen extends StatefulWidget {
  DashboardScreen({this.auth, this.loginCallback, this.db, this.fs});

  final Firestore db;
  final FirebaseStorage fs;
  final BaseAuth auth;
  final VoidCallback loginCallback;

  final String title = "Dashboard";
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin<DashboardScreen> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  String _userEmail = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _userEmail = user?.email;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        _userEmail = user.email;
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
      _userEmail = "";
    });
  }

  Widget loadingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return loadingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return AuthPage(
          db: widget.db,
          auth: widget.auth,
          fs: widget.fs,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return DashboardMain(
            auth: widget.auth,
            db: widget.db,
            fs: widget.fs,
            logoutCallback: logoutCallback,
            userEmail: _userEmail,
            userId: _userId,
          );
        } else
          return loadingScreen();
        break;
      default:
        return loadingScreen();
    }
  }
}
